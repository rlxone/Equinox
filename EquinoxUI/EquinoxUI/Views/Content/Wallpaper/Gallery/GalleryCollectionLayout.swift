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

extension GalleryCollectionLayout {
    private enum Constants {
        static let minimumInteritemSpacing: CGFloat = 20.0
        static let minimumLineSpacing: CGFloat = 20.0
        static let sectionInset = NSEdgeInsets(top: 25, left: 40, bottom: 0, right: 40)
        static let maxRowItemsCount = 4
        static let midRowItemsCount = 3
        static let minRowItemsCount = 2
        static let imageAspect: CGFloat = GalleryCollectionContentView.imageAspect
        static let verticalPadding: CGFloat = 10
        static let stacksSolarHeight: CGFloat = 72
        static let stacksTimeHeight: CGFloat = 40
        static let minRowItemsRange = 0..<3
        static let midRowItemsRange = 3..<10
    }
}

// MARK: - Class

public final class GalleryCollectionLayout: NSCollectionViewFlowLayout {
    public override init() {
        super.init()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup

    private func setup() {
        scrollDirection = .vertical
        minimumInteritemSpacing = Constants.minimumInteritemSpacing
        minimumLineSpacing = Constants.minimumLineSpacing
        sectionInset = Constants.sectionInset
        sectionFootersPinToVisibleBounds = true
    }
    
    // MARK: - Public

    public var type: GalleryCollectionView.CollectionType = .solar

    public func calculateItemSize(for width: CGFloat) -> NSSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let itemsPerRow = calculateRowItemsCount(for: numberOfItems)
        let itemWidth = calculateItemWidth(for: width, itemsPerRow: itemsPerRow)
        let itemHeight = calculateItemHeight(for: itemWidth)

        return .init(width: itemWidth, height: itemHeight)
    }
    
    // MARK: - Private

    private func calculateItemWidth(for width: CGFloat, itemsPerRow: Int) -> CGFloat {
        let padding = minimumInteritemSpacing * CGFloat(itemsPerRow - 1)
        let inset = sectionInset.left + sectionInset.right
        let usefulWidth = CGFloat(width - inset) - padding
        let width = usefulWidth / CGFloat(itemsPerRow)

        return floor(width)
    }

    private func calculateItemHeight(for width: CGFloat) -> CGFloat {
        var height: CGFloat

        switch type {
        case .solar:
            height = width * Constants.imageAspect
            height += Constants.verticalPadding
            height += Constants.stacksSolarHeight

        case .time:
            height = width * Constants.imageAspect
            height += Constants.verticalPadding
            height += Constants.stacksTimeHeight

        case .appearance:
            height = width * Constants.imageAspect
        }

        return ceil(height)
    }

    private func calculateRowItemsCount(for count: Int) -> Int {
        switch type {
        case .solar, .time:
            switch count {
            case Constants.minRowItemsRange:
                return Constants.minRowItemsCount

            case Constants.midRowItemsRange:
                return Constants.midRowItemsCount

            default:
                return Constants.maxRowItemsCount
            }

        case .appearance:
            return Constants.minRowItemsCount
        }
    }
}
