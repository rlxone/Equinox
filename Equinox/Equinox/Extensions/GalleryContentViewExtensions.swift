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

import EquinoxAssets
import EquinoxUI

// MARK: - GalleryContentView.Style

extension GalleryContentView.Style {
    static var `default`: GalleryContentView.Style {
        return .init(
            galleryCollectionStyle: .init(
                galleryCollectionItemStyle: .default,
                galleryCollectionFooterStyle: .default,
                galleryCollectionGapStyle: .default
            ),
            dragStyle: .init(
                ownStyle: .init(
                    image: Image.images,
                    backgroundColor: Color.dragBackground,
                    dashColor: Color.dragDash,
                    highlightDashColor: Color.controlAccent
                ),
                titleStyle: .init(
                    font: Font.title1(.heavy),
                    color: Color.label
                ),
                supplementaryStyle: .init(
                    font: Font.title2(.regular),
                    color: Color.secondaryLabel
                ),
                alternativeStyle: .init(
                    font: Font.title2(.regular),
                    color: Color.tertiaryLabel
                ),
                browseStyle: .default
            )
        )
    }
}

// MARK: - GalleryCollectionViewItem.Style

extension GalleryCollectionViewItem.Style {
    static var `default`: GalleryCollectionViewItem.Style {
        return .init(
            galleryContentStyle: .init(
                galleryDragStyle: .default,
                buttonsStyle: .default,
                coordinatesStyle: .default,
                timeStyle: .default,
                tooltipStyle: .default
            )
        )
    }
}

// MARK: - GalleryCollectionImageView.Style

extension GalleryCollectionImageView.Style {
    static var `default`: GalleryCollectionImageView.Style {
        return .init(
            ownStyle: .init(
                backgroundColor: Color.wallpaperContent,
                dashColor: Color.wallpaperContentBorder,
                highlightDashColor: Color.controlAccent
            ),
            numberStyle: .init(
                font: Font.title3(.regular),
                color: Color.secondaryLabel
            ),
            smallNumberStyle: .init(
                font: Font.callout(.regular),
                color: Color.secondaryLabel
            )
        )
    }
}

// MARK: - GalleryCollectionButtonsView.Style

extension GalleryCollectionButtonsView.Style {
    static var `default`: GalleryCollectionButtonsView.Style {
        return .init(
            ownStyle: .init(
                stackBackgroundColor: Color.wallpaperContent,
                stackVibrantBackgroundColor: Color.clear,
                stackBorderColor: Color.wallpaperContentBorder
            ),
            dynamicStyle: .init(
                lightColor: Color.wallpaperDynamicLight,
                darkColor: Color.wallpaperDynamicDark,
                borderColor: Color.wallpaperButtonBorder
            ),
            primaryStyle: .init(
                backgroundColor: Color.wallpaperPrimaryBackground,
                alternativeColor: Color.controlAccent,
                borderColor: Color.wallpaperButtonBorder
            )
        )
    }
}

// MARK: - GalleryCollectionCoordinatesView.Style

extension GalleryCollectionCoordinatesView.Style {
    static var `default`: GalleryCollectionCoordinatesView.Style {
        return .init(
            ownStyle: .init(
                stackBackgroundColor: Color.wallpaperContent,
                stackBorderColor: Color.wallpaperContentBorder,
                flashColor: Color.controlAccent
            ),
            separatorStyle: .init(
                color: Color.wallpaperContentBorder
            ),
            altitudeStyle: .init(
                font: Font.callout(.regular),
                color: Color.label
            ),
            azimuthStyle: .init(
                font: Font.callout(.regular),
                color: Color.label
            )
        )
    }
}

// MARK: - GalleryCollectionTimeView.Style

extension GalleryCollectionTimeView.Style {
    static var `default`: GalleryCollectionTimeView.Style {
        return .init(
            ownStyle: .init(
                stackBackgroundColor: Color.wallpaperContent,
                stackBorderColor: Color.wallpaperContentBorder
            ),
            timeStyle: .init(
                font: Font.callout(.regular),
                color: Color.label
            )
        )
    }
}

// MARK: - TooltipWindow.Style

extension TooltipWindow.Style {
    static var `default`: TooltipWindow.Style {
        return .init(
            ownStyle: .init(
                backgroundColor: Color.clear
            ),
            tooltipStyle: .init(
                ownStyle: .init(
                    borderColor: Color.tooltipBorder
                ),
                titleStyle: .init(
                    font: Font.body(.medium),
                    color: Color.label
                ),
                descriptionStyle: .init(
                    font: Font.callout(.regular),
                    color: Color.secondaryLabel
                )
            )
        )
    }
}

// MARK: - GalleryCollectionFooterView.Style

extension GalleryCollectionFooterItem.Style {
    static var `default`: GalleryCollectionFooterItem.Style {
        return .init(
            footerStyle: .init(
                ownStyle: .init(
                    backgroundColor: Color.wallpaperFooterBackground
                ),
                infoStyle: .init(
                    font: Font.callout(.regular),
                    color: Color.label
                )
            )
        )
    }
}

// MARK: - GalleryCollectionInnerGapView.Style

extension GalleryCollectionInnerGapItem.Style {
    static var `default`: GalleryCollectionInnerGapItem.Style {
        return .init(
            backgroundColor: Color.controlAccent
        )
    }
}
