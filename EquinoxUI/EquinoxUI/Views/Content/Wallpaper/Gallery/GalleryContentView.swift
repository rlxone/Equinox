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

// MARK: - Enums, Structs

extension GalleryContentView {
    public struct Style {
        let galleryCollectionStyle: GalleryCollectionView.Style
        let dragStyle: DragView.Style

        public init(
            galleryCollectionStyle: GalleryCollectionView.Style,
            dragStyle: DragView.Style
        ) {
            self.galleryCollectionStyle = galleryCollectionStyle
            self.dragStyle = dragStyle
        }
    }
    
    enum TooltipIdentifier: String {
        case appearance
        case primary
    }
}

// MARK: - Class

public final class GalleryContentView: View {
    private lazy var dragView = DragView()
    private lazy var galleryCollectionView = GalleryCollectionView()
    
    // MARK: - Initializer
    
    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(galleryCollectionView)
        addSubview(dragView)
    }
    
    private func setupConstraints() {
        dragView.translatesAutoresizingMaskIntoConstraints = false
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dragView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dragView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dragView.topAnchor.constraint(equalTo: topAnchor),
            dragView.bottomAnchor.constraint(equalTo: bottomAnchor),

            galleryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            galleryCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            galleryCollectionView.topAnchor.constraint(equalTo: topAnchor),
            galleryCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public

    public var style: Style? {
        didSet {
            galleryCollectionView.style = style?.galleryCollectionStyle
            dragView.style = style?.dragStyle
        }
    }

    public var collectionType: GalleryCollectionView.CollectionType {
        get {
            return galleryCollectionView.collectionType
        }
        set {
            galleryCollectionView.collectionType = newValue
        }
    }

    public weak var delegate: GalleryCollectionViewDelegate? {
        get {
            return galleryCollectionView.delegate
        }
        set {
            galleryCollectionView.delegate = newValue
        }
    }

    public var galleryTextList: GalleryTextList? {
        didSet {
            galleryCollectionView.textList = galleryTextList
        }
    }

    public var dragTitle: String {
        get {
            return dragView.title
        }
        set {
            dragView.title = newValue
        }
    }

    public var dragSupplementaryTitle: String {
        get {
            return dragView.supplementaryTitle
        }
        set {
            dragView.supplementaryTitle = newValue
        }
    }

    public var dragAlternativeTitle: String {
        get {
            return dragView.alternativeTitle
        }
        set {
            dragView.alternativeTitle = newValue
        }
    }

    public var dragBrowseTitle: String {
        get {
            return dragView.browseTitle
        }
        set {
            dragView.browseTitle = newValue
        }
    }

    public var dragBrowseAction: Button.Action? {
        didSet {
            dragView.browseAction = dragBrowseAction
        }
    }

    public var isDragHidden: Bool {
        get {
            return dragView.isHidden
        }
        set {
            dragView.isHidden = newValue
        }
    }

    public var isDragHighlighted: Bool {
        get {
            return dragView.isHighlighed
        }
        set {
            dragView.isHighlighed = newValue
        }
    }

    public var isSelectionEnabled: Bool {
        get {
            return galleryCollectionView.isSelectionEnabled
        }
        set {
            galleryCollectionView.isSelectionEnabled = newValue
        }
    }
    
    public var selectedIndexPaths: Set<IndexPath> {
        get {
            return galleryCollectionView.selectedIndexPaths
        }
        set {
            galleryCollectionView.selectedIndexPaths = newValue
        }
    }

    public func setCollectionVisibility(_ isVisible: Bool, animated: Bool) {
        galleryCollectionView.setCollectionVisibility(isVisible, animated: animated)
    }

    public func reloadCollection(_ data: GalleryData, type: GalleryCollectionView.ReloadType) {
        galleryCollectionView.reload(data, type: type)
    }

    public func performCollectionUpdates(
        _ updates: GalleryCollectionView.PerformUpdateAction,
        completion: GalleryCollectionView.PerformUpdateCompletionAction?
    ) {
        galleryCollectionView.performUpdates(updates, completion: completion)
    }

    public func insertCollectionItems(at indexPaths: Set<IndexPath>) {
        galleryCollectionView.insertItems(at: indexPaths)
    }

    public func deselectCollectionItems(at indexPaths: Set<IndexPath>) {
        galleryCollectionView.deselectItems(at: indexPaths)
    }

    public func moveCollectionItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        galleryCollectionView.moveItem(at: indexPath, to: newIndexPath)
    }

    public func deleteCollectionItems(at indexPaths: Set<IndexPath>) {
        galleryCollectionView.deleteItems(at: indexPaths)
    }

    public func updateItem(at index: Int, model: GalleryModel, animated: Bool) {
        galleryCollectionView.updateItem(at: index, model: model, animated: animated)
    }
    
    public func flashItems(at indexPaths: Set<IndexPath>) {
        galleryCollectionView.flashItems(at: indexPaths)
    }
}
