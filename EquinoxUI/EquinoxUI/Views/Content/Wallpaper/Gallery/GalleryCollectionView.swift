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
    func draggingSessionBegan(at indexPaths: Set<IndexPath>)
    func draggingSessionEnded()
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
        static let visibilityAnimationDuration: TimeInterval = 0.2
    }

    // macOS 26 scroll edge effects are backed by this AppKit internal view.
    private enum ScrollPocket {
        static let className = "NSScrollPocket"
        static let edgeKey = "edge"
        static let edgeSelector = Selector((edgeKey))
        static let bottomEdge = 1
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
    private var dragSnapshots: [IndexPath: NSImageView] = [:]
    private var dragFlagsMonitor: Any?
    private var dragItemFrames: [NSRect] = []
    private var copyInsertIndex: Int?
    private let copyInsertIndicator = GalleryCollectionInnerGapItem()

    
    private lazy var dataSource: GalleryCollectionDataSource = {
        let dataSource = GalleryCollectionDataSource(collectionView: collectionView)
        dataSource.delegate = self
        return dataSource
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
        if let monitor = dragFlagsMonitor { NSEvent.removeMonitor(monitor) }
    }

    public override func layout() {
        super.layout()
        updateScrollPocketVisibility()
        updateDragSnapshots()
    }

    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        DispatchQueue.main.async { [weak self] in
            self?.updateScrollPocketVisibility()
        }
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
            copyInsertIndicator.style = style?.galleryCollectionGapStyle
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

    }

    public func performUpdates(_ updates: PerformUpdateAction, completion: PerformUpdateCompletionAction?) {
        dataSource.performUpdates(updates, completion: completion)
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

    @objc
    private func scrollViewBoundsDidChange(_ notification: Notification) {
        delegate?.didScroll(self)
        collectionView.visibleItems().forEach {
            updateTrackingAreas(view: $0.view)
        }
        updateScrollPocketVisibility()
    }
    
    @objc
    private func scrollViewFrameDidChange(_ notification: Notification) {
        collectionLayout.invalidateLayout()
        updateScrollPocketVisibility()
    }
    
    private func captureDragSnapshot(at indexPath: IndexPath) {
        guard dragSnapshots[indexPath] == nil,
              let view = collectionView.item(at: indexPath)?.view,
              let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds)
        else { return }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        let image = NSImage(size: view.bounds.size)
        image.addRepresentation(bitmap)
        let snapshot = NSImageView(frame: view.frame)
        snapshot.image = image
        snapshot.isHidden = true
        collectionView.addSubview(snapshot)
        dragSnapshots[indexPath] = snapshot
    }

    private func updateDragSnapshots(
        flags: NSEvent.ModifierFlags = NSEvent.modifierFlags
    ) {
        let show = flags.contains(.option)
        for (indexPath, snapshot) in dragSnapshots {
            if let attributes = collectionView.layoutAttributesForItem(
                at: indexPath
            ) {
                snapshot.frame = attributes.frame
            }
            snapshot.isHidden = !show
        }
    }

    private func clearCopyInsertIndicator() {
        copyInsertIndex = nil
        copyInsertIndicator.removeFromSuperview()
    }

    private func updateCopyInsertIndicator(at point: NSPoint) -> Int? {
        guard let insertion = GalleryDragOperations.insertion(
            at: point, frames: dragItemFrames
        ) else { return nil }
        copyInsertIndicator.frame = insertion.marker
        if copyInsertIndicator.superview == nil {
            collectionView.addSubview(copyInsertIndicator)
        }
        copyInsertIndex = insertion.index
        return insertion.target
    }

    private func clearDragSnapshots() {
        clearCopyInsertIndicator()
        dragItemFrames = []
        if let monitor = dragFlagsMonitor { NSEvent.removeMonitor(monitor) }
        dragFlagsMonitor = nil
        dragSnapshots.values.forEach { $0.removeFromSuperview() }
        dragSnapshots.removeAll()
    }

    private func updateTrackingAreas(view: NSView) {
        for subview in view.subviews {
            subview.updateTrackingAreas()
            updateTrackingAreas(view: subview)
        }
    }

    private func updateScrollPocketVisibility() {
        guard #available(macOS 26.0, *) else {
            return
        }

        subviews
            .filter(isBottomScrollPocket)
            .forEach { $0.isHidden = true }
    }

    private func isBottomScrollPocket(_ view: NSView) -> Bool {
        guard isScrollPocket(view),
              view.responds(to: ScrollPocket.edgeSelector),
              let edge = view.value(forKey: ScrollPocket.edgeKey) as? NSNumber
        else {
            return false
        }

        return edge.intValue == ScrollPocket.bottomEdge
    }

    private func isScrollPocket(_ view: NSView) -> Bool {
        if let scrollPocketClass = NSClassFromString(ScrollPocket.className),
           view.isKind(of: scrollPocketClass) {
            return true
        }

        return String(describing: type(of: view)) == ScrollPocket.className
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
        return .zero
    }

    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let writer = delegate?.pasteboardWriter(
            for: collectionView, indexPath: indexPath
        )
        if writer != nil { captureDragSnapshot(at: indexPath) }
        return writer
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        draggingSession session: NSDraggingSession,
        willBeginAt screenPoint: NSPoint,
        forItemsAt indexPaths: Set<IndexPath>
    ) {
        self.collectionView.noteDragStarted()
        delegate?.draggingSessionBegan(at: indexPaths)
        dragItemFrames = (0..<collectionView.numberOfItems(inSection: 0))
            .compactMap { index in
                collectionView.layoutAttributesForItem(
                    at: IndexPath(item: index, section: 0)
                )?.frame
            }
        if dragItemFrames.count != collectionView.numberOfItems(inSection: 0) {
            dragItemFrames = []
        }
        for indexPath in Array(dragSnapshots.keys)
            where !indexPaths.contains(indexPath) {
            dragSnapshots.removeValue(forKey: indexPath)?.removeFromSuperview()
        }
        updateDragSnapshots()
        dragFlagsMonitor = NSEvent.addLocalMonitorForEvents(
            matching: .flagsChanged
        ) { [weak self] event in
            self?.updateDragSnapshots(flags: event.modifierFlags)
            return event
        }
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        draggingSession session: NSDraggingSession,
        endedAt screenPoint: NSPoint,
        dragOperation operation: NSDragOperation
    ) {
        clearDragSnapshots()
        delegate?.draggingSessionEnded()
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>
    ) -> NSDragOperation {
        updateDragSnapshots()
        let operation = delegate?.validateDrop(
            collectionView,
            validateDrop: draggingInfo,
            proposedIndexPath: proposedDropIndexPath,
            dropOperation: proposedDropOperation
        ) ?? []
        if operation == .copy,
           draggingInfo.draggingSource as? NSCollectionView == collectionView {
            let point = collectionView.convert(
                draggingInfo.draggingLocation, from: nil
            )
            if let target = updateCopyInsertIndicator(at: point) {
                proposedDropIndexPath.pointee = IndexPath(
                    item: target, section: 0
                ) as NSIndexPath
                proposedDropOperation.pointee = .on
            }
        } else {
            clearCopyInsertIndicator()
        }
        return operation
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        shouldChangeItemsAt indexPaths: Set<IndexPath>,
        to highlightState: NSCollectionViewItem.HighlightState
    ) -> Set<IndexPath> {
        if highlightState == .asDropTarget, copyInsertIndex != nil {
            return []
        }
        return indexPaths
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        acceptDrop draggingInfo: NSDraggingInfo,
        indexPath: IndexPath,
        dropOperation: NSCollectionView.DropOperation
    ) -> Bool {
        let destination = copyInsertIndex.map {
            IndexPath(item: $0, section: 0)
        } ?? indexPath
        clearCopyInsertIndicator()
        return delegate?.acceptDrop(
            collectionView,
            acceptDrop: draggingInfo,
            indexPath: destination,
            dropOperation: dropOperation
        ) ?? false
    }
}

// MARK: - GalleryInternalCollectionViewDelegate

extension GalleryCollectionView: GalleryInternalCollectionViewDelegate {
    public func didDraggingExited(_ sender: NSDraggingInfo?) {
        clearCopyInsertIndicator()
        delegate?.draggingExited(sender)
    }

    public func didDeleteBackward(_ sender: Any?) {
        delegate?.didDeleteBackward(for: collectionView)
    }

    public func pinFooterOffset(_ collectionView: NSCollectionView) -> CGFloat {
        return 0
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
    }
}

// MARK: - NSMenuDelegate

extension GalleryCollectionView: NSMenuDelegate {
    public func menuNeedsUpdate(_ menu: NSMenu) {
        delegate?.menuNeedsUpdate(menu)
    }
}
