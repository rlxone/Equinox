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

public protocol GalleryCollectionDataSourceDelegate: AnyObject {
    func updateFooter()
}

// MARK: - Enums, Structs

extension GalleryCollectionDataSource {
    private enum Identifier: String {
        case galleryItem
        case footer
        case innerGap

        var identifier: NSUserInterfaceItemIdentifier {
            return NSUserInterfaceItemIdentifier(rawValue: rawValue)
        }
    }
}

// MARK: - Class

public final class GalleryCollectionDataSource: NSObject {
    private weak var collectionView: GalleryInternalCollectionView?
    private var data: GalleryData?

    // MARK: - Initializer

    public init(collectionView: GalleryInternalCollectionView) {
        self.collectionView = collectionView
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        collectionView?.register(
            GalleryCollectionViewItem.self,
            forItemWithIdentifier: Identifier.galleryItem.identifier
        )
        collectionView?.register(
            GalleryCollectionFooterItem.self,
            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionFooter,
            withIdentifier: Identifier.footer.identifier
        )
        collectionView?.register(
            GalleryCollectionInnerGapItem.self,
            forSupplementaryViewOfKind: NSCollectionView.elementKindInterItemGapIndicator,
            withIdentifier: Identifier.innerGap.identifier
        )
    }

    // MARK: - Public

    public var style: GalleryCollectionView.Style? {
        didSet {
            collectionView?.reloadData()
        }
    }

    public weak var itemDelegate: GalleryCollectionViewDelegate? {
        didSet {
            collectionView?.reloadData()
        }
    }

    public weak var delegate: GalleryCollectionDataSourceDelegate?

    public var textList: GalleryTextList? {
        didSet {
            collectionView?.reloadData()
        }
    }

    public var collectionType: GalleryCollectionView.CollectionType? {
        didSet {
            collectionView?.reloadData()
        }
    }

    public func reload(_ data: GalleryData, type: GalleryCollectionView.ReloadType) {
        self.data = data

        switch type {
        case .hard:
            collectionView?.reloadData()

        case .soft:
            break

        case .visible:
            reloadVisibleCells()
        }
    }

    public func performUpdates(
        _ updates: GalleryCollectionView.PerformUpdateAction,
        completion: GalleryCollectionView.PerformUpdateCompletionAction?
    ) {
        collectionView?.animator().performBatchUpdates(updates, completionHandler: completion)
    }

    public func insertItems(at indexPaths: Set<IndexPath>) {
        collectionView?.insertItems(at: indexPaths)
    }

    public func deselectItems(at indexPaths: Set<IndexPath>) {
        collectionView?.deselectItems(at: indexPaths)
    }

    public func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        collectionView?.moveItem(at: indexPath, to: newIndexPath)
    }

    public func deleteItems(at indexPaths: Set<IndexPath>) {
        collectionView?.deleteItems(at: indexPaths)
    }

    public func updateItem(at index: Int, model: GalleryModel, animated: Bool) {
        guard let view = collectionView?.item(at: index) as? GalleryCollectionViewItem else {
            return
        }
        view.setModel(model, animated: animated)
    }

    // MARK: - Private

    private func configure(_ item: GalleryCollectionViewItem, model: GalleryModel) {
        item.collectionType = collectionType
        item.delegate = itemDelegate
        item.style = style?.galleryCollectionItemStyle
        item.setModel(model, animated: false)
        item.textList = textList
    }

    private func reloadVisibleCells() {
        guard let data = data else {
            return
        }
        let visibleIndexPaths = collectionView?.indexPathsForVisibleItems() ?? []
        for indexPath in visibleIndexPaths {
            guard let item = collectionView?.item(at: indexPath) as? GalleryCollectionViewItem else {
                return
            }
            let model = data.items[indexPath.item]
            configure(item, model: model)
        }
    }
}

// MARK: - NSCollectionViewDataSource

extension GalleryCollectionDataSource: NSCollectionViewDataSource {
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.items.count ?? 0
    }

    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard
            let item = collectionView.makeItem(
                withIdentifier: Identifier.galleryItem.identifier,
                for: indexPath
            ) as? GalleryCollectionViewItem
        else {
            fatalError("Wrong cell identifier")
        }
        if let data = data {
            let model = data.items[indexPath.item]
            configure(item, model: model)
        }
        return item
    }

    public func collectionView(
        _ collectionView: NSCollectionView,
        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
        at indexPath: IndexPath
    ) -> NSView {
        switch kind {
        case NSCollectionView.elementKindSectionFooter:
            guard let view = collectionView.makeSupplementaryView(
                ofKind: kind,
                withIdentifier: Identifier.footer.identifier,
                for: indexPath
            ) as? GalleryCollectionFooterItem else {
                return NSView()
            }
            view.style = style?.galleryCollectionFooterStyle
            view.info = data?.info
            view.action = { [weak self] in
                self?.collectionView?.selectAll(nil)
                self?.delegate?.updateFooter()
            }
            return view

        case NSCollectionView.elementKindInterItemGapIndicator:
            guard let view = collectionView.makeSupplementaryView(
                ofKind: kind,
                withIdentifier: Identifier.innerGap.identifier,
                for: indexPath
            ) as? GalleryCollectionInnerGapItem else {
                return NSView()
            }
            view.style = style?.galleryCollectionGapStyle
            return view

        default:
            return NSView()
        }
    }
}
