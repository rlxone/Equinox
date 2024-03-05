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

// MARK: - Protocols

protocol WallpaperGalleryDragControllerDelegate: AnyObject {
    var isDragHighlighted: Bool { get set }

    func refreshCollectionData(_ index: Int, field: GalleryModel.MutateField, sender: Any?)
    func processInternalCollectionItems(_ indexPaths: [IndexPath], insertIndexPath: IndexPath)
    func processExternalCollectionItems(_ urls: [URL], insertIndexPath: IndexPath)
    func deleteCollectionItems()
    func canValidateCollectionDrag() -> Bool
    func loadImage(url: URL, completion: @escaping (NSImage?) -> Void)
    func collectionDidScroll()
    func collectionMenuNeedsUpdate(_ menu: NSMenu)
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

final class WallpaperGalleryDragController {
    private let type: WallpaperType
    
    // MARK: - Initializer
    
    init(type: WallpaperType) {
        self.type = type
    }
    
    // MARK: - Public

    weak var delegate: WallpaperGalleryDragControllerDelegate?

    // MARK: - Private
    
    private func dropInternalItems(collectionView: NSCollectionView, draggingInfo: NSDraggingInfo, insertIndexPath: IndexPath) -> Bool {
        guard let pasteboardItems = draggingInfo.draggingPasteboard.pasteboardItems else {
            return false
        }

        let indexPaths: [IndexPath] = pasteboardItems.compactMap { item in
            guard
                let pasteboardData = item.data(forType: Constants.collectionDragType),
                let indexPath = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSIndexPath.self, from: pasteboardData) as? IndexPath
            else {
                return nil
            }
            return indexPath
        }

        delegate?.processInternalCollectionItems(indexPaths, insertIndexPath: insertIndexPath)

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
    func registerDraggedTypes(for collectionView: NSCollectionView) {
        collectionView.registerForDraggedTypes([
            .fileURL,
            Constants.collectionDragType
        ])
    }

    func pasteboardWriter(for collectionView: NSCollectionView, indexPath: IndexPath) -> NSPasteboardWriting? {
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

        guard delegate?.canValidateCollectionDrag() == true else {
            return dragOperation
        }

        delegate?.isDragHighlighted = true

        if proposedDropOperation.pointee == .on {
            proposedDropOperation.pointee = .before
        }

        if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == collectionView {
            dragOperation = [.move]
        } else if draggingInfo.draggingPasteboard.canReadObject(forClasses: [NSURL.self], options: Constants.pasteboardOptions) {
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

    func draggingExited(_ sender: NSDraggingInfo?) {
        delegate?.isDragHighlighted = false
    }

    func didDeleteBackward(for collectionView: NSCollectionView) {
        guard !collectionView.selectionIndexes.isEmpty else {
            return
        }
        delegate?.deleteCollectionItems()
    }

    func loadImage(url: URL, completion: @escaping (NSImage?) -> Void) {
        delegate?.loadImage(url: url, completion: completion)
    }

    func mutate(_ collectionView: NSCollectionView, model: GalleryModel, field: GalleryModel.MutateField, sender: Any?) {
        let index = model.number - 1
        delegate?.refreshCollectionData(index, field: field, sender: sender)
    }

    func didScroll(_ scrollView: NSScrollView) {
        delegate?.collectionDidScroll()
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.collectionMenuNeedsUpdate(menu)
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
            let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: pasteboardData),
            let results = unarchivedData as? [String],
            let azimuthString = results.first,
            let altitudeString = results.last,
            let number = view.number
        else {
            return false
        }

        let azimuth = Double(azimuthString)
        let altitude = Double(altitudeString)
        let index = number - 1

        delegate?.refreshCollectionData(index, field: .azimuth(azimuth), sender: view)
        delegate?.refreshCollectionData(index, field: .altitude(altitude), sender: view)

        view.azimuth = azimuthString
        view.altitude = altitudeString

        return true
    }
}
