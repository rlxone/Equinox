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

public protocol FloatingTextFieldDelegate: AnyObject {
    func textDidChange(_ textField: FloatingTextField)
    func textDidTab(for view: NSView)
    func textDidBackTab(for view: NSView)
}

// MARK: - Enums, Structs

extension FloatingTextField {
    private enum Constants {
        static let separator: Character = "."
        static let minus: Character = "-"
        static let charactersIn = "1234567890."
    }
}

// MARK: - Class

public final class FloatingTextField: NSTextField {
    public override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        delegate = self
    }

    // MARK: - Public

    public weak var floatingDelegate: FloatingTextFieldDelegate?

    public var value: Double? {
        var value = stringValue
        if !value.isEmpty, value.last == Constants.separator {
            value.removeLast()
        }
        return Double(value)
    }

    // MARK: - Private

    private func mutateStringValue() {
        var value = stringValue
        let containsMinus = stringValue.first == Constants.minus

        let floatingCharacterSet = NSCharacterSet(charactersIn: Constants.charactersIn).inverted
        let characters = value.components(separatedBy: floatingCharacterSet)
        value = characters.joined()

        if containsMinus {
            value = "\(Constants.minus)\(value)"
        }

        let components = value.components(separatedBy: ".")

        switch components.count {
        case 0:
            value = String()

        case 1:
            value = components[0]

        case 2:
            value = "\(components[0]).\(components[1])"

        default:
            value.removeLast()
        }

        stringValue = value
    }
}

// MARK: - NSTextFieldDelegate

extension FloatingTextField: NSTextFieldDelegate {
    public func controlTextDidChange(_ obj: Notification) {
        mutateStringValue()
        floatingDelegate?.textDidChange(self)
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        guard
            let view = obj.object as? NSView,
            let textMovementInt = obj.userInfo?["NSTextMovement"] as? Int,
            let textMovement = NSTextMovement(rawValue: textMovementInt)
        else {
            return
        }
        
        switch textMovement {
        case .tab:
            floatingDelegate?.textDidTab(for: view)
            
        case .backtab:
            floatingDelegate?.textDidBackTab(for: view)
            
        default:
            break
        }
    }
}
