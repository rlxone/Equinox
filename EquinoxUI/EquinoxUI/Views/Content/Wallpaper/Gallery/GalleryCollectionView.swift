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

// MARK: - Protocols

public protocol GalleryCollectionViewDelegate: GalleryCollectionViewItemDelegate {
    func registerDraggedTypes(for collectionView: NSCollectionView)
    func pasteboardWriter(for collectionView: NSCollectionView, indexPath: IndexPath) -> NSPasteboardWriting?
    func validateDrop(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>
    ) -> NSDragOperation
    func acceptDrop(
        _ collectionView: NSCollectionView,
        acceptDrop draggingInfo: NSDraggingInfo,
        indexPath: IndexPath,
        dropOperation: NSCollectionView.DropOperation
    ) -> Bool
    func draggingExited(_ sender: NSDraggingInfo?)
    func didDeleteBackward(for collectionView: NSCollectionView)
    func didScroll(_ scrollView: NSScrollView)
    func menuNeedsUpdate(_ menu: NSMenu)
}

// MARK: - Enums, Structs

extension GalleryCollectionView {
    public typealias PerformUpdateAction = () -> Void
    public typealias PerformUpdateCompletionAction = (Bool) -> Void

    public struct Style {
        let galleryCollectionItemStyle: GalleryCollectionViewItem.Style
        let galleryCollectionFooterStyle: GalleryCollectionFooterItem.Style
        let galleryCollectionGapStyle: GalleryCollectionInnerGapItem.Style

        public init(
            galleryCollectionItemStyle: GalleryCollectionViewItem.Style,
            galleryCollectionFooterStyle: GalleryCollectionFooterItem.Style,
            galleryCollectionGapStyle: GalleryCollectionInnerGapItem.Style
        ) {
            self.galleryCollectionItemStyle = galleryCollectionItemStyle
            self.galleryCollectionFooterStyle = galleryCollectionFooterStyle
            self.galleryCollectionGapStyle = galleryCollectionGapStyle
        }
    }

    public enum ReloadType {
        case hard
        case soft
        case visible
    }

    public enum CollectionType {
        case solar
        case time
        case appearance
    }

    private enum Constants {
        static let footerHeight: CGFloat = 72
        static let pinFooterOffset: CGFloat = 20
        static let visibilityAnimationDuration: TimeInterval = 0.2
        static let footerAnimationDelay: TimeInterval = 1
    }
}

// MARK: - Class

public final class GalleryCollectionView: NSScrollView {
    private lazy var collectionView: GalleryInternalCollectionView = {
        let collectionView = GalleryInternalCollectionView()
        collectionView.delegate = self
        collectionView.internalDelegate = self
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    private lazy var collectionLayout = GalleryCollectionLayout()
    private lazy var semaphore = DispatchSemaphore(value: 0)
    
    private lazy var dataSource: GalleryCollectionDataSource = {
        let dataSource = GalleryCollectionDataSource(collectionView: collectionView)
        dataSource.delegate = self
        return dataSource
    }()
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    // MARK: - Initializer

    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Life Cycle

    public override func layout() {
        super.layout()
        collectionView.collectionViewLayout?.invalidateLayout()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupMenu()
        setupNotifications()
    }

    private func setupView() {
        collectionView.collectionViewLayout = collectionLayout
        collectionView.dataSource = dataSource
        
        verticalScroller?.scrollerStyle = .overlay
        autohidesScrollers = true
        documentView = collectionView
        contentView.postsBoundsChangedNotifications = true
        contentView.postsFrameChangedNotifications = true
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        collectionView.menu = menu
        menu.delegate = self
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewBoundsDidChange(_:)),
            name: NSView.boundsDidChangeNotification,
            object: contentView
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollViewFrameDidChange(_:)),
            name: NSView.frameDidChangeNotification,
            object: contentView
        )
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            dataSource.style = style
        }
    }

    public var textList: GalleryTextList? {
        didSet {
            dataSource.textList = textList
        }
    }

    public weak var delegate: GalleryCollectionViewDelegate? {
        didSet {
            delegate?.registerDraggedTypes(for: collectionView)
            dataSource.itemDelegate = delegate
        }
    }

    public var collectionType: CollectionType = .solar {
        didSet {
            collectionLayout.type = collectionType
            dataSource.collectionType = collectionType
        }
    }

    public var isSelectionEnabled: Bool {
        get {
            return collectionView.isSelectable
        }
        set {
            collectionView.isSelectable = newValue
        }
    }
    
    public var selectedIndexPaths: Set<IndexPath> {
        get {
            return collectionView.selectionIndexPaths
        }
        set {
            collectionView.selectionIndexPaths = newValue
        }
    }
    
    public func setCollectionVisibility(_ isVisible: Bool, animated: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.visibilityAnimationDuration
            
            self.animator().alphaValue = isVisible ? 1 : 0
        }
    }

    public func reload(_ data: GalleryData, type: ReloadType) {
        dataSource.reload(data, type: type)

        switch type {
        case .hard, .visible:
            updateFooterPin()

        case .soft:
            break
        }
    }

    public func performUpdates(_ updates: PerformUpdateAction, completion: PerformUpdateCompletionAction?) {
        dataSource.performUpdates(updates, completion: completion)
        updateFooterPin()
    }

    public func insertItems(at indexPaths: Set<IndexPath>) {
        dataSource.insertItems(at: indexPaths)
    }

    public func deselectItems(at indexPaths: Set<IndexPath>) {
        dataSource.deselectItems(at: indexPaths)
    }

    public func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        dataSource.moveItem(at: indexPath, to: newIndexPath)
    }

    public func deleteItems(at indexPaths: Set<IndexPath>) {
        dataSource.deleteItems(at: indexPaths)
    }

    public func updateItem(at index: Int, model: GalleryModel, animated: Bool) {
        dataSource.updateItem(at: index, model: model, animated: animated)
    }
    
    public func flashItems(at indexPaths: Set<IndexPath>) {
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems()
        let flashIndexPaths = visibleIndexPaths.intersection(indexPaths)
        flashIndexPaths.forEach {
            let item = collectionView.item(at: $0) as? GalleryCollectionViewItem
            item?.flash()
        }
    }

    // MARK: - Private

    private func updateFooterPin() {
        let views: [NSView] = collectionView.visibleSupplementaryViews(ofKind: NSCollectionView.elementKindSectionFooter)
        guard let footerView = views.first as? GalleryCollectionFooterItem else {
            return
        }
        updateFooterPin(footerView: footerView)
    }

    private func updateFooterPin(footerView: GalleryCollectionFooterItem) {
        let offset = documentVisibleRect.origin.y + frame.height

        operationQueue.cancelAllOperations()
        footerView.animate(isHidden: false)

        if offset < collectionLayout.collectionViewContentSize.height - Constants.pinFooterOffset {
            let operation = BlockOperation()
            operation.addExecutionBlock { [weak self, weak operation] in
                guard let operation = operation, !operation.isCancelled else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.footerAnimationDelay) { [weak self, weak operation] in
                    guard let operation = operation, !operation.isCancelled else {
                        self?.semaphore.signal()
                        return
                    }
                    footerView.animate(isHidden: true)
                    self?.semaphore.signal()
                }
                self?.semaphore.wait()
            }
            operationQueue.addOperation(operation)
        }
    }
    
    @objc
    private func scrollViewBoundsDidChange(_ notification: Notification) {
        delegate?.didScroll(self)
        collectionView.visibleItems().forEach {
            updateTrackingAreas(view: $0.view)
        }
        updateFooterPin()
    }
    
    @objc
    private func scrollViewFrameDidChange(_ notification: Notification) {
        collectionLayout.invalidateLayout()
    }
    
    private func updateTrackingAreas(view: NSView) {
        for subview in view.subviews {
            subview.updateTrackingAreas()
            updateTrackingAreas(view: subview)
        }
    }
}

// MARK: - NSCollectionViewDelegate

extension GalleryCollectionView: NSCollectionViewDelegate {
    public func collectionView(
        _ collectionView: NSCollectionView,
        layout collectionViewLayout: NSCollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> NSSize {
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        guard numberOfItems > 0 else {
            return .zero
        }
        return .init(width: 0, height: Constants.footerHeight)
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        willDisplaySupplementaryView view: NSView,
        forElementKind elementKind: NSCollectionView.SupplementaryElementKind,
        at indexPath: IndexPath
    ) {
        if elementKind == NSCollectionView.elementKindSectionFooter {
            guard let footerView = view as? GalleryCollectionFooterItem else {
                return
            }
            updateFooterPin(footerView: footerView)
        }
    }

    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        return delegate?.pasteboardWriter(for: collectionView, indexPath: indexPath)
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>
    ) -> NSDragOperation {
        return delegate?.validateDrop(
            collectionView,
            validateDrop: draggingInfo,
            proposedIndexPath: proposedDropIndexPath,
            dropOperation: proposedDropOperation
        ) ?? []
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        acceptDrop draggingInfo: NSDraggingInfo,
        indexPath: IndexPath,
        dropOperation: NSCollectionView.DropOperation
    ) -> Bool {
        return delegate?.acceptDrop(
            collectionView,
            acceptDrop: draggingInfo,
            indexPath: indexPath,
            dropOperation: dropOperation
        ) ?? false
    }
}

// MARK: - GalleryInternalCollectionViewDelegate

extension GalleryCollectionView: GalleryInternalCollectionViewDelegate {
    public func didDraggingExited(_ sender: NSDraggingInfo?) {
        delegate?.draggingExited(sender)
    }

    public func didDeleteBackward(_ sender: Any?) {
        delegate?.didDeleteBackward(for: collectionView)
    }

    public func pinFooterOffset(_ collectionView: NSCollectionView) -> CGFloat {
        return Constants.pinFooterOffset
    }
}

// MARK: - NSCollectionViewDelegateFlowLayout

extension GalleryCollectionView: NSCollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: NSCollectionView,
        layout collectionViewLayout: NSCollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> NSSize {
        return collectionLayout.calculateItemSize(for: collectionView.frame.width)
    }
}

// MARK: - GalleryCollectionDataSourceDelegate

extension GalleryCollectionView: GalleryCollectionDataSourceDelegate {
    public func updateFooter() {
        updateFooterPin()
    }
}

// MARK: - NSMenuDelegate

extension GalleryCollectionView: NSMenuDelegate {
    public func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.menuNeedsUpdate(menu)
    }
}
