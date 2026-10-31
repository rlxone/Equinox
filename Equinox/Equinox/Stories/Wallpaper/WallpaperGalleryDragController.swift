// Copyright (c) 2021 Dmitry Meduho
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import AppKit
import EquinoxCore
import EquinoxUI
import UniformTypeIdentifiers

// MARK: - Protocols

protocol WallpaperGalleryDragControllerDelegate: AnyObject {
    var isDragHighlighted: Bool { get set }

    func refreshCollectionData(_ index: Int, field: GalleryModel.MutateField, sender: Any?)
    func processInternalCollectionItems(_ indexPaths: [IndexPath], insertIndexPath: IndexPath)
    func copyInternalCollectionItems(
        _ indexPaths: [IndexPath], insertIndexPath: IndexPath
    )
    func processExternalCollectionItems(_ urls: [URL], insertIndexPath: IndexPath)
    func deleteCollectionItems()
    func canValidateCollectionDrag() -> Bool
    func loadImage(
        model: GalleryModel,
        completion: @escaping (NSImage?) -> Void
    )
    func collectionMenuNeedsUpdate(_ menu: NSMenu)
    func filePromiseDetails(at indexPath: IndexPath) -> (URL, Int?, String)?
}

// MARK: - Enums, Structs

extension WallpaperGalleryDragController {
    private enum DragTypes: String {
        case jpeg = "public.jpeg"
        case png = "public.png"
        case tiff = "public.tiff"
        case heic = "public.heic"
    }

    private enum Constants {
        static let pasteboardOptions = [
            NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: [
                DragTypes.jpeg.rawValue,
                DragTypes.png.rawValue,
                DragTypes.tiff.rawValue,
                DragTypes.heic.rawValue
            ]
        ]
        static let collectionDragType = NSPasteboard.PasteboardType("com.equinox.drag.collection")
        static let solarDragType = NSPasteboard.PasteboardType("com.equinox.drag.solar")
    }
}

// MARK: - Class

final class WallpaperGalleryDragController: NSObject {
    private let type: WallpaperType
    private var dragSession = GalleryDragSession()
    private let filePromiseQueue = OperationQueue()
    
    // MARK: - Initializer
    
    init(type: WallpaperType) {
        self.type = type
        super.init()
    }
    
    // MARK: - Public

    weak var delegate: WallpaperGalleryDragControllerDelegate?

    // MARK: - Private
    
    private func dropInternalItems(collectionView: NSCollectionView, draggingInfo: NSDraggingInfo, insertIndexPath: IndexPath) -> Bool {
        let resolvedIndexPaths = dragSession.indexPaths
        guard !resolvedIndexPaths.isEmpty else { return false }
        if NSEvent.modifierFlags.contains(.option) {
            delegate?.copyInternalCollectionItems(
                resolvedIndexPaths, insertIndexPath: insertIndexPath
            )
        } else {
            delegate?.processInternalCollectionItems(
                resolvedIndexPaths, insertIndexPath: insertIndexPath
            )
        }

        return true
    }

    private func dropExternalItems(collectionView: NSCollectionView, draggingInfo: NSDraggingInfo, insertIndexPath: IndexPath) -> Bool {
        guard let urls = draggingInfo.draggingPasteboard.readObjects(
            forClasses: [NSURL.self],
            options: Constants.pasteboardOptions
        ) as? [URL] else {
            return false
        }

        delegate?.processExternalCollectionItems(urls, insertIndexPath: insertIndexPath)

        return true
    }
}

// MARK: - GalleryCollectionViewDelegate

extension WallpaperGalleryDragController: GalleryCollectionViewDelegate {
    func didScroll(_ scrollView: NSScrollView) {
    }

    func registerDraggedTypes(for collectionView: NSCollectionView) {
        let promiseTypes = NSFilePromiseReceiver.readableDraggedTypes.map {
            NSPasteboard.PasteboardType($0)
        }
        collectionView.registerForDraggedTypes(
            [.fileURL, Constants.collectionDragType] + promiseTypes
        )
    }

    func pasteboardWriter(for collectionView: NSCollectionView, indexPath: IndexPath) -> NSPasteboardWriting? {
        if let (url, sourceIndex, filename) = delegate?.filePromiseDetails(
            at: indexPath
        ) {
            let details = WallpaperFramePromiseDetails(
                sourceURL: url,
                sourceIndex: sourceIndex,
                filename: filename
            )
            let provider = NSFilePromiseProvider(
                fileType: UTType(
                    filenameExtension: URL(fileURLWithPath: filename)
                        .pathExtension
                )?.identifier ?? UTType.data.identifier,
                delegate: self
            )
            provider.userInfo = details
            return provider
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: indexPath as NSIndexPath, requiringSecureCoding: true) else {
            return nil
        }
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setData(data, forType: Constants.collectionDragType)
        return pasteboardItem
    }

    func validateDrop(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>
    ) -> NSDragOperation {
        var dragOperation: NSDragOperation = []

        let isInternalDrag =
            (draggingInfo.draggingSource as? NSCollectionView) == collectionView

        guard
            isInternalDrag
                || delegate?.canValidateCollectionDrag() == true
        else {
            return dragOperation
        }

        delegate?.isDragHighlighted = true

        if proposedDropOperation.pointee == .on {
            let indexPath = proposedDropIndexPath.pointee as IndexPath
            let point = collectionView.convert(
                draggingInfo.draggingLocation, from: nil
            )
            if let attributes = collectionView.layoutAttributesForItem(
                at: indexPath
            ), point.x >= attributes.frame.midX {
                proposedDropIndexPath.pointee = IndexPath(
                    item: indexPath.item + 1, section: indexPath.section
                ) as NSIndexPath
            }
            proposedDropOperation.pointee = .before
        }

        if isInternalDrag {
            if NSEvent.modifierFlags.contains(.option) {
                if delegate?.canValidateCollectionDrag() == true {
                    dragOperation = .copy
                }
            } else {
                dragOperation = .move
            }
        } else if draggingInfo.draggingPasteboard.canReadObject(
            forClasses: [NSURL.self],
            options: Constants.pasteboardOptions
        ) {
            dragOperation = [.copy]
        }

        return dragOperation
    }

    func acceptDrop(
        _ collectionView: NSCollectionView,
        acceptDrop draggingInfo: NSDraggingInfo,
        indexPath: IndexPath,
        dropOperation: NSCollectionView.DropOperation
    ) -> Bool {
        delegate?.isDragHighlighted = false

        var result: Bool

        if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == collectionView {
            result = dropInternalItems(collectionView: collectionView, draggingInfo: draggingInfo, insertIndexPath: indexPath)
        } else {
            result = dropExternalItems(collectionView: collectionView, draggingInfo: draggingInfo, insertIndexPath: indexPath)
        }

        return result
    }

    func draggingSessionBegan(at indexPaths: Set<IndexPath>) {
        dragSession.begin(at: indexPaths)
    }

    func draggingSessionEnded() {
        dragSession.end()
    }

    func draggingExited(_ sender: NSDraggingInfo?) {
        delegate?.isDragHighlighted = false
    }

    func didDeleteBackward(for collectionView: NSCollectionView) {
        guard !collectionView.selectionIndexes.isEmpty else {
            return
        }
        delegate?.deleteCollectionItems()
    }

    func loadImage(
        model: GalleryModel,
        completion: @escaping (NSImage?) -> Void
    ) {
        delegate?.loadImage(model: model, completion: completion)
    }

    func mutate(_ collectionView: NSCollectionView, model: GalleryModel, field: GalleryModel.MutateField, sender: Any?) {
        let index = model.number - 1
        delegate?.refreshCollectionData(index, field: field, sender: sender)
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.collectionMenuNeedsUpdate(menu)
    }
}

private final class WallpaperFramePromiseDetails: NSObject {
    let sourceURL: URL
    let sourceIndex: Int?
    let filename: String

    init(sourceURL: URL, sourceIndex: Int?, filename: String) {
        self.sourceURL = sourceURL
        self.sourceIndex = sourceIndex
        self.filename = filename
        super.init()
    }
}

extension WallpaperGalleryDragController: NSFilePromiseProviderDelegate {
    func filePromiseProvider(
        _ filePromiseProvider: NSFilePromiseProvider,
        fileNameForType fileType: String
    ) -> String {
        return (filePromiseProvider.userInfo as? WallpaperFramePromiseDetails)?
            .filename ?? "image.heic"
    }

    func operationQueue(for filePromiseProvider: NSFilePromiseProvider)
        -> OperationQueue {
        return filePromiseQueue
    }

    func filePromiseProvider(
        _ filePromiseProvider: NSFilePromiseProvider,
        writePromiseTo url: URL,
        completionHandler: @escaping (Error?) -> Void
    ) {
        do {
            guard let details = filePromiseProvider.userInfo
                    as? WallpaperFramePromiseDetails else {
                throw ImageError.invalidImageFormat
            }
            let sourceData = try Data(contentsOf: details.sourceURL)
            let output: Data
            if let sourceIndex = details.sourceIndex {
                output = try ImageCoreImpl().extractHEICFrame(
                    from: sourceData,
                    at: sourceIndex
                )
            } else {
                output = sourceData
            }
            try output.write(to: url)
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
}

// MARK: - GalleryCollectionContentViewDelegate

extension WallpaperGalleryDragController: GalleryCollectionContentViewDelegate {
    func registerForDraggedTypes(_ view: GalleryCollectionContentView) {
        switch type {
        case .solar:
            view.registerForDraggedTypes([Constants.solarDragType])

        case .time, .appearance:
            break
        }
    }

    func draggingEntered(_ view: GalleryCollectionContentView, sender: NSDraggingInfo) -> NSDragOperation {
        guard sender.draggingPasteboard.canReadItem(withDataConformingToTypes: [Constants.solarDragType.rawValue]) else {
            return .init()
        }
        return .copy
    }

    func performDragOperation(_ view: GalleryCollectionContentView, sender: NSDraggingInfo) -> Bool {
        guard
            let pasteboardItem = sender.draggingPasteboard.pasteboardItems?.first,
            let pasteboardData = pasteboardItem.data(forType: Constants.solarDragType),
            let values = SolarDragValues(data: pasteboardData),
            let number = view.number
        else {
            return false
        }

        let azimuth = Double(values.azimuth)
        let altitude = Double(values.altitude)
        let index = number - 1

        delegate?.refreshCollectionData(index, field: .azimuth(azimuth), sender: view)
        delegate?.refreshCollectionData(index, field: .altitude(altitude), sender: view)

        view.azimuth = values.azimuth
        view.altitude = values.altitude

        return true
    }
}
