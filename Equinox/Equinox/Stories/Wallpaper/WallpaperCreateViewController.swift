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
import EquinoxAssets
import EquinoxCore
import EquinoxUI

// MARK: - Protocols

protocol WallpaperCreateViewControllerDelegate: AnyObject {
    func createViewControllerDismissWasInteracted()
    func createViewControllerNewWasInteracted()
    func createViewControllerSetWasInteracted()
    func createViewControllerRepeatWasInteracted()
    func createViewControllerShouldNotify(_ text: String)
}

// MARK: - Enums, Structs

extension WallpaperCreateViewController {
    private enum Constants {
        static let thumbnailSize = NSSize(width: 768, height: 425.25)
        static let imageFilename = "wallpaper.heic"
        static let defaultDelay: TimeInterval = 0.3
    }
}

// MARK: - Class

final class WallpaperCreateViewController: ViewController {
    private let type: WallpaperType
    private let imageAttributes: [ImageAttributes]
    private let wallpaperService: WallpaperService
    private let imageProvider: ImageProvider
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private lazy var contentView: CreateContentView = {
        let view = CreateContentView()
        view.style = .default
        view.animatedImageDelegate = self
        view.dragAnimatedImageDelegate = self
        return view
    }()
    
    private var createdImage: Data?

    // MARK: - Initializer

    init(
        type: WallpaperType,
        imageAttributes: [ImageAttributes],
        wallpaperService: WallpaperService,
        imageProvider: ImageProvider
    ) {
        self.type = type
        self.imageAttributes = imageAttributes
        self.wallpaperService = wallpaperService
        self.imageProvider = imageProvider
        super.init()
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        createWallpaper()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupActions()
    }

    private func setupView() {        
        contentView.saveButtonTitle = Localization.Wallpaper.Create.save
        contentView.setButtonTitle = Localization.Wallpaper.Create.set
        contentView.shareButtonTitle = Localization.Wallpaper.Create.share
        contentView.createButtonTitle = Localization.Wallpaper.Create.new
        contentView.cancelButtonTitle = Localization.Wallpaper.Create.cancel
        
        contentView.startProcessAnimation()
    }
    
    private func setupActions() {
        contentView.saveButtonAction = { [weak self] _ in
            self?.saveImage(notify: true)
        }
        contentView.setButtonAction = { [weak self] _ in
            self?.setWallpaper()
        }
        contentView.createButtonAction = { [weak self] _ in
            self?.createNew()
        }
        contentView.cancelButtonAction = { [weak self] _ in
            self?.delegate?.createViewControllerDismissWasInteracted()
        }
        contentView.shareButtonAction = { [weak self] button in
            self?.shareWallpaper(relativeTo: button)
        }
    }
    
    // MARK: - Public
    
    weak var delegate: WallpaperCreateViewControllerDelegate?
    
    func continueSaveImage() {
        saveImage(notify: false) { [weak self] savedUrl in
            guard let mainScreen = NSScreen.main, let url = savedUrl else {
                self?.delegate?.createViewControllerShouldNotify(Localization.Wallpaper.Create.setError)
                return
            }
            do {
                try NSWorkspace.shared.setDesktopImageURL(url, for: mainScreen, options: [:])
                self?.delegate?.createViewControllerShouldNotify(Localization.Wallpaper.Create.setSuccess)
            } catch {
                self?.delegate?.createViewControllerShouldNotify(Localization.Wallpaper.Create.setError)
            }
        }
    }
    
    // MARK: - Private
    
    private func createWallpaper() {
        DispatchQueue.global().asyncAfter(deadline: .now() + Constants.defaultDelay) { [weak self] in
            let operation = BlockOperation()
            operation.addExecutionBlock { [weak self] in
                guard let self = self else {
                    return
                }
                do {
                    self.createdImage = try self.wallpaperService.createWallpaper(self.imageAttributes) { step, steps in
                        let progress = Float(step) / Float(steps)
                        DispatchQueue.main.async {
                            self.contentView.setProgress(progress, animated: true)
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.defaultDelay) {
                        self.completeWallpaperCreation()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.failureWallpaperCreation()
                    }
                }
            }
            self?.operationQueue.addOperation(operation)
        }
    }
    
    private func shareWallpaper(relativeTo view: NSView) {
        contentView.isUserInteractionsEnabled = false
        operationQueue.addOperation { [weak self] in
            do {
                let temporaryDirectoryUrl = FileManager.default.temporaryDirectory
                let filename = Constants.imageFilename
                let temporaryFileUrl = temporaryDirectoryUrl.appendingPathComponent(filename)
                try self?.createdImage?.write(to: temporaryFileUrl)
                DispatchQueue.main.async {
                    let sharingPicker = NSSharingServicePicker(items: [temporaryFileUrl])
                    sharingPicker.show(relativeTo: .zero, of: view, preferredEdge: .maxY)
                }
            } catch {
                DispatchQueue.main.async {
                    self?.delegate?.createViewControllerShouldNotify(Localization.Wallpaper.Create.cantShare)
                }
            }
            DispatchQueue.main.async {
                self?.contentView.isUserInteractionsEnabled = true
            }
        }
    }
    
    private func completeWallpaperCreation() {
        let localizedType = getLocalizedWallpaperType()
        
        var tags: [String] = [
            localizedType,
            Localization.Shared.images(param1: imageAttributes.count)
        ]

        if let createdImage = createdImage {
            let formattedFilesize = getFormattedFilesize(filesize: UInt64(createdImage.count))
            tags.append(formattedFilesize)
        }
        
        contentView.statusText = Localization.Wallpaper.Create.success
        contentView.descriptionText = Localization.Wallpaper.Create.successDescription
        contentView.tags = tags
        contentView.completeProcessAnimation(with: .success)
        contentView.isProgressHidden = true
        
        NSApp.requestUserAttention(.informationalRequest)
    }
    
    private func failureWallpaperCreation() {
        let localizedType = getLocalizedWallpaperType()
        
        contentView.tags = [localizedType]
        contentView.statusText = Localization.Wallpaper.Create.failure
        contentView.descriptionText = Localization.Wallpaper.Create.failureDescription
        contentView.completeProcessAnimation(with: .failure)
        contentView.isProgressHidden = true
        
        NSApp.requestUserAttention(.criticalRequest)
    }
    
    private func saveImage(notify: Bool, completion: ((URL?) -> Void)? = nil) {
        guard let window = view.window else {
            return
        }

        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = Constants.imageFilename

        savePanel.beginSheetModal(for: window) { [weak self] result in
            guard
                let self = self,
                let createdImage = self.createdImage,
                result == .OK,
                let url = savePanel.directoryURL?.appendingPathComponent(savePanel.nameFieldStringValue)
            else {
                return
            }
            do {
                try createdImage.write(to: url)
                if notify {
                    self.delegate?.createViewControllerShouldNotify(Localization.Wallpaper.Create.fileSaved)
                }
                completion?(url)
            } catch {
                completion?(nil)
            }
        }
    }
    
    private func createNew() {
        guard let window = view.window else {
            return
        }

        let alert = NSAlert()
        alert.messageText = Localization.Wallpaper.Create.newTitle
        alert.informativeText = Localization.Wallpaper.Create.newDescription
        alert.alertStyle = .informational
        alert.addButton(withTitle: Localization.Wallpaper.Create.create)
        alert.addButton(withTitle: Localization.Wallpaper.Create.repeat)
        alert.addButton(withTitle: Localization.Wallpaper.Create.cancel)

        alert.beginSheetModal(for: window) { [weak self] response in
            switch response {
            case .alertFirstButtonReturn:
                self?.delegate?.createViewControllerNewWasInteracted()

            case .alertSecondButtonReturn:
                self?.delegate?.createViewControllerRepeatWasInteracted()

            default:
                break
            }
        }

        alert.window.center()
    }
    
    private func setWallpaper() {
        switch type {
        case .solar, .time:
            delegate?.createViewControllerSetWasInteracted()
            
        case .appearance:
            continueSaveImage()
        }
    }
    
    private func getFormattedFilesize(filesize: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(filesize), countStyle: .file)
    }
    
    private func getLocalizedWallpaperType() -> String {
        switch type {
        case .solar:
            return Localization.Wallpaper.Create.solarBased
            
        case .time:
            return Localization.Wallpaper.Create.timeBased
            
        case .appearance:
            return Localization.Wallpaper.Create.appearanceBased
        }
    }
}

// MARK: - AnimatedImageViewDelegate

extension WallpaperCreateViewController: AnimatedImageViewDelegate {
    func numberOfImages() -> Int {
        return imageAttributes.count
    }

    func image(for index: Int, completion: @escaping (NSImage?) -> Void) {
        let url = imageAttributes[index].url
        imageProvider.loadImage(url: url, resizeMode: .resized(size: Constants.thumbnailSize, respectAspect: true)) { image in
            completion(image)
        }
    }
}

// MARK: - DragAnimatedImageViewDelegate

extension WallpaperCreateViewController: DragAnimatedImageViewDelegate {
    func canBeDragged(_ dragAnimatedImageView: DragAnimatedImageView) -> Bool {
        return createdImage != nil
    }

    func beginDragginSession(for dragAnimatedImageView: DragAnimatedImageView, event: NSEvent) {
        guard let url = imageAttributes.first(where: { $0.primary })?.url else {
            return
        }
        
        imageProvider.loadImage(url: url, resizeMode: .resized(size: Constants.thumbnailSize, respectAspect: true)) { image in
            let provider = NSFilePromiseProvider(fileType: kUTTypeImage as String, delegate: self)
            let draggingItem = NSDraggingItem(pasteboardWriter: provider)
            draggingItem.setDraggingFrame(dragAnimatedImageView.bounds, contents: image)
            dragAnimatedImageView.beginDraggingSession(with: [draggingItem], event: event, source: self)
        }
    }
}

// MARK: - NSDraggingSource

extension WallpaperCreateViewController: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .outsideApplication:
            return .copy

        case .withinApplication:
            return []
            
        @unknown default:
            return []
        }
    }
}

// MARK: - NSFilePromiseProviderDelegate

extension WallpaperCreateViewController: NSFilePromiseProviderDelegate {
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
        return Constants.imageFilename
    }

    func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
        return operationQueue
    }

    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {
        do {
            try createdImage?.write(to: url)
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }
}
