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

extension TypeView {
    public typealias Action = (Int) -> Void
    
    public struct Style {
        let headerStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style
        let lineStyle: LineView.Style
        let itemStyle: TypeItemView.Style
        
        public init(
            headerStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style,
            lineStyle: LineView.Style,
            itemStyle: TypeItemView.Style
        ) {
            self.headerStyle = headerStyle
            self.descriptionStyle = descriptionStyle
            self.lineStyle = lineStyle
            self.itemStyle = itemStyle
        }
    }
    
    private enum KeyCode: UInt16 {
        case down = 125
        case up = 126
        case enter = 36
    }
    
    private enum Constants {
        static let stackViewSpacing: CGFloat = 0
        static let headerLabelLeadingOffset: CGFloat = 16
        static let headerLabelTopOffset: CGFloat = 16
        static let descriptionLabelLeadingOffset: CGFloat = 16
        static let descriptionLabelTopOffset: CGFloat = 2
        static let lineHeight: CGFloat = 1
        static let lineTopOffset: CGFloat = 14
        static let stackViewOffset: CGFloat = 10
    }
}

// MARK: - Class

public final class TypeView: View {
    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.distribution = .fill
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()
    private lazy var headerLabel = StyledLabel()
    private lazy var descriptionLabel = StyledLabel()
    private lazy var lineView = LineView()
    
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
        addSubview(stackView)
        addSubview(headerLabel)
        addSubview(descriptionLabel)
        addSubview(lineView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.headerLabelLeadingOffset),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.headerLabelTopOffset),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.descriptionLabelLeadingOffset),
            
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.lineTopOffset),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.stackViewOffset),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.stackViewOffset),
            stackView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: Constants.stackViewOffset)
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

    public var items: [TypeItemView.Item] = [] {
        didSet {
            clearSubviews()
            addItems()
        }
    }
    
    public var action: Action?

    public var selectedIndex: Int? {
        didSet {
            stackView.arrangedSubviews
                .compactMap { $0 as? TypeItemView }
                .forEach {
                    $0.isSelected = $0.index == selectedIndex
                }
        }
    }
    
    public var headerText: String? {
        didSet {
            headerLabel.stringValue = headerText ?? String()
        }
    }
    
    public var descriptionText: String? {
        didSet {
            descriptionLabel.stringValue = descriptionText ?? String()
        }
    }
    
    // MARK: - Private

    private func addItems() {
        for (index, item) in items.enumerated() {
            let itemView = TypeItemView()
            itemView.item = item
            itemView.index = index
            itemView.style = style?.itemStyle
            
            itemView.selectionAction = { [weak self] item in
                self?.selectedIndex = item.index
            }
            itemView.action = { [weak self] item in
                guard let selectedIndex = item.index else {
                    return
                }
                self?.action?(selectedIndex)
            }
            
            stackView.addArrangedSubview(itemView)
            
            itemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                itemView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
            ])
        }
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(with event: NSEvent) {
        let keyCode = KeyCode(rawValue: event.keyCode)
        
        switch keyCode {
        case .down:
            selectDown()
            
        case .up:
            selectUp()
            
        case .enter:
            guard let selectedIndex = selectedIndex else {
                return
            }
            action?(selectedIndex)
            
        default:
            break
        }
    }
    
    private func selectUp() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        
        let upperbound = 0
        let nextIndex = selectedIndex - 1
        
        self.selectedIndex = nextIndex == upperbound - 1 ? items.count - 1 : nextIndex
    }
    
    private func selectDown() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        
        let upperbound = items.count
        let nextIndex = selectedIndex + 1
        
        self.selectedIndex = nextIndex == upperbound ? 0 : nextIndex
    }

    private func clearSubviews() {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
        }
    }

    private func stylize() {
        headerLabel.style = style?.headerStyle
        descriptionLabel.style = style?.descriptionStyle
        lineView.style = style?.lineStyle
        stackView.arrangedSubviews
            .compactMap { $0 as? TypeItemView }
            .forEach {
                $0.style = style?.itemStyle
            }
    }
}
