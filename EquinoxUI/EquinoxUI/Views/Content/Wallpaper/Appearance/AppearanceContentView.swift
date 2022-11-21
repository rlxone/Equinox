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

extension AppearanceContentView {
    public typealias Action = (Model) -> Void

    public struct Style {
        let appearanceItemStyle: AppearanceItemView.Style
        let lineStyle: LineView.Style

        public init(appearanceItemStyle: AppearanceItemView.Style, lineStyle: LineView.Style) {
            self.appearanceItemStyle = appearanceItemStyle
            self.lineStyle = lineStyle
        }
    }

    public struct Model {
        public let title: String
        public let description: String
        public let appearanceType: AppearanceType

        public init(
            title: String,
            description: String,
            appearanceType: AppearanceType
        ) {
            self.title = title
            self.description = description
            self.appearanceType = appearanceType
        }
    }

    private enum Constants {
        static let stackViewSpacing: CGFloat = 0
        static let lineHeight: CGFloat = 1
    }
}

// MARK: - Class

public final class AppearanceContentView: View {
    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.orientation = .vertical
        stackView.spacing = Constants.stackViewSpacing
        stackView.alignment = .left
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(stackView)
    }

    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var data: [Model] = [] {
        didSet {
            reload()
        }
    }

    public func selectItem(at selectIndex: Int) {
        var index = 0
        for subview in stackView.arrangedSubviews {
            if let item = subview as? AppearanceItemView {
                if index == selectIndex {
                    item.isSelected = true
                    break
                }
                index += 1
            }
        }
    }

    public var didSelect: Action?

    // MARK: - Private

    private func stylize() {
        for subview in stackView.arrangedSubviews {
            if let subview = subview as? AppearanceItemView {
                subview.style = style?.appearanceItemStyle
            }
            if let subview = subview as? LineView {
                subview.style = style?.lineStyle
            }
        }
    }

    private func reload() {
        clearSubviews()

        for (index, model) in data.enumerated() {
            let appearanceItemView = makeItem(
                index: index,
                title: model.title,
                description: model.description,
                appearanceType: model.appearanceType
            )
            stackView.addArrangedSubview(appearanceItemView)
            appearanceItemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                appearanceItemView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                appearanceItemView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ])
            let isLast = index == data.count - 1
            if !isLast {
                let lineView = makeLineView()
                stackView.addArrangedSubview(lineView)
                lineView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight)
                ])
            }
        }
    }

    private func makeItem(
        index: Int,
        title: String,
        description: String,
        appearanceType: AppearanceType
    ) -> AppearanceItemView {
        let view = AppearanceItemView()
        view.index = index
        view.title = title
        view.titleDescription = description
        view.appearanceType = appearanceType
        view.style = style?.appearanceItemStyle

        view.didSelect = { [weak self] index in
            guard let self = self, let index = index else {
                return
            }
            let model = self.data[index]
            self.didSelect?(model)
        }

        return view
    }

    private func makeLineView() -> LineView {
        let view = LineView()
        view.style = style?.lineStyle
        return view
    }

    private func clearSubviews() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
        }
    }
}
