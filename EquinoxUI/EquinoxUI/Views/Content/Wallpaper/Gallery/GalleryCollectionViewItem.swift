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

public protocol GalleryCollectionViewItemDelegate: GalleryCollectionContentViewDelegate {
    func loadImage(url: URL, completion: @escaping (NSImage?) -> Void)
    func mutate(_ collectionView: NSCollectionView, model: GalleryModel, field: GalleryModel.MutateField, sender: Any?)
}

// MARK: - Enums, Structs

extension GalleryCollectionViewItem {
    public struct Style {
        let galleryContentStyle: GalleryCollectionContentView.Style

        public init(galleryContentStyle: GalleryCollectionContentView.Style) {
            self.galleryContentStyle = galleryContentStyle
        }
    }
}

// MARK: - Class

public final class GalleryCollectionViewItem: NSCollectionViewItem {
    private let contentView = GalleryCollectionContentView()
    private var model: GalleryModel?

    // MARK: - Life Cycle

    public override func loadView() {
        view = contentView
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        contentView.image = nil
    }

    public override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            contentView.isHiglighted = shouldBeHighlighted()
        }
    }

    public override var isSelected: Bool {
        didSet {
            contentView.isHiglighted = shouldBeHighlighted()
        }
    }

    // MARK: - Public

    public weak var delegate: GalleryCollectionViewItemDelegate?

    public var style: Style? {
        didSet {
            contentView.style = style?.galleryContentStyle
        }
    }

    public var collectionType: GalleryCollectionView.CollectionType? {
        didSet {
            contentView.collectionType = collectionType
        }
    }

    public var textList: GalleryTextList? {
        didSet {
            guard let textList = textList else {
                return
            }
            configure(textList)
        }
    }

    public func setModel(_ model: GalleryModel, animated: Bool) {
        self.model = model
        configure(model, animated: animated)
    }
    
    public func flash() {
        contentView.flash()
    }

    // MARK: - Private
    
    private func shouldBeHighlighted() -> Bool {
        let isForSelection = highlightState == .forSelection
        let isAsDropTarget = highlightState == .asDropTarget
        let isNotForDeselection = isSelected && highlightState != .forDeselection
        
        return isForSelection || isAsDropTarget || isNotForDeselection
    }
    
    private func configure(_ model: GalleryModel, animated: Bool) {
        configureActions(for: model)

        contentView.delegate = delegate
        contentView.number = model.number
        contentView.isPrimary = model.primary

        switch model.appearance {
        case .all:
            contentView.setAppearanceType(.all, animated: animated)

        case .light:
            contentView.setAppearanceType(.light, animated: animated)

        case .dark:
            contentView.setAppearanceType(.dark, animated: animated)
        }

        if let azimuth = model.azimuth {
            contentView.azimuth = String(azimuth)
        } else {
            contentView.azimuth = String()
        }

        if let altitude = model.altitude {
            contentView.altitude = String(altitude)
        } else {
            contentView.altitude = String()
        }

        if let time = model.time {
            contentView.time = time
        } else {
            contentView.time = Date()
        }

        delegate?.loadImage(url: model.url) { [weak self] image in
            guard self?.model == model else {
                return
            }
            self?.contentView.image = image
        }
    }
    
    private func configureActions(for model: GalleryModel) {
        contentView.onAzimuthChange = { [weak model, weak self] textField in
            guard let model = model, let collectionView = self?.collectionView else {
                return
            }
            self?.delegate?.mutate(collectionView, model: model, field: .azimuth(textField.value), sender: textField)
        }

        contentView.onAltitudeChange = { [weak model, weak self] textField in
            guard let model = model, let collectionView = self?.collectionView else {
                return
            }
            self?.delegate?.mutate(collectionView, model: model, field: .altitude(textField.value), sender: textField)
        }

        contentView.onTimeChange = { [weak model, weak self] picker in
            guard let model = model, let collectionView = self?.collectionView else {
                return
            }
            self?.delegate?.mutate(collectionView, model: model, field: .time(picker.dateValue), sender: picker)
        }

        contentView.onPrimaryChange = { [weak model, weak self] button in
            guard let model = model, let collectionView = self?.collectionView else {
                return
            }
            self?.delegate?.mutate(collectionView, model: model, field: .primary(button.isSelected), sender: button)
        }

        contentView.onAppearanceTypeChange = { [weak model, weak self] button in
            guard let model = model, let collectionView = self?.collectionView else {
                return
            }
            
            let appearanceType: AppearanceType

            switch button.getType() {
            case .all:
                appearanceType = .all

            case .dark:
                appearanceType = .dark

            case .light:
                appearanceType = .light
            }

            self?.delegate?.mutate(collectionView, model: model, field: .appearance(appearanceType), sender: button)
        }
    }
    
    private func configure(_ textList: GalleryTextList) {
        contentView.azimuthText = textList.azimuthText
        contentView.azimuthPlaceholder = textList.azimuthPlaceholder
        contentView.altitudeText = textList.altitudeText
        contentView.altitudePlaceholder = textList.altitudePlaceholder
        contentView.timeText = textList.timeText
        contentView.appearanceTooltipTitle = textList.appearanceTooltipTitle
        contentView.appearanceTooltipDescription = textList.appearanceTooltipDescription
        contentView.primaryTooltipTitle = textList.primaryTooltipTitle
        contentView.primaryTooltipDescription = textList.primaryTooltipDescription
    }
}
