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
import EquinoxUI
import Foundation

// MARK: - Enums, Structs

extension NavigationController {
    private enum Constants {
        static let defaultAnimationTimeInterval: TimeInterval = 0.35
        static let pushAnimationPreviousShiftAspect: CGFloat = 3
        static let pushAnimationPreviousAlpha: CGFloat = 0.3
        static let dismissAnimationTimeInterval: TimeInterval = 0.25
    }
}

// MARK: - Class

class NavigationController: ViewController {
    private var rootViewController: ViewController
    
    // MARK: - Initializer
    
    init(rootViewController: ViewController) {
        self.rootViewController = rootViewController
        super.init()
    }
    
    // MARK: - Life Cycle

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup

    private func setup() {
        addChild(rootViewController)
        view.addSubview(rootViewController.view)
        rootViewController.view.autoresizingMask = [.width, .height]
        rootViewController.view.frame = view.frame
    }
    
    // MARK: - Public

    func push(_ controller: ViewController, animated: Bool = true) {
        addChild(controller)

        let previousController = children[children.count - 2]

        view.addSubview(controller.view)
        controller.view.autoresizingMask = [.width, .height]
        controller.view.frame = view.frame.offsetBy(dx: view.frame.width, dy: 0)

        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = Constants.defaultAnimationTimeInterval
                context.timingFunction = .init(name: .easeInEaseOut)

                controller.view.animator().frame = .init(origin: .zero, size: view.frame.size)
                previousController.view.animator().frame = .init(
                    origin: .init(x: -view.frame.width / Constants.pushAnimationPreviousShiftAspect, y: 0),
                    size: view.frame.size
                )
                previousController.view.animator().alphaValue = Constants.pushAnimationPreviousAlpha
            }, completionHandler: {
                previousController.view.isHidden = true
            })
        } else {
            controller.view.frame = .init(origin: .zero, size: view.frame.size)
            previousController.view.frame = .init(
                origin: .init(x: -view.frame.width / Constants.pushAnimationPreviousShiftAspect, y: 0),
                size: view.frame.size
            )
            previousController.view.alphaValue = Constants.pushAnimationPreviousAlpha
            previousController.view.isHidden = true
        }
    }

    func popBack(animated: Bool = true) {
        guard children.count > 1, let controller = children.last else {
            return
        }

        let previousController = children[children.count - 2]
        previousController.view.isHidden = false

        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = Constants.defaultAnimationTimeInterval
                context.timingFunction = .init(name: .easeInEaseOut)

                controller.view.animator().frame = .init(
                    origin: .init(x: view.frame.width, y: 0),
                    size: view.frame.size
                )
                previousController.view.animator().frame = .init(origin: .zero, size: view.frame.size)
                previousController.view.animator().alphaValue = 1
            }, completionHandler: {
                controller.view.removeFromSuperview()
                controller.removeFromParent()
            })
        } else {
            controller.view.frame = .init(
                origin: .init(x: view.frame.width, y: 0),
                size: view.frame.size
            )
            previousController.view.frame = .init(origin: .zero, size: view.frame.size)
            previousController.view.alphaValue = 1
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
    }
    
    func present(_ controller: ViewController, animated: Bool = true) {
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.autoresizingMask = [.width, .height]
        controller.view.frame = view.frame
        controller.view.alphaValue = 0

        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = Constants.defaultAnimationTimeInterval
                context.timingFunction = .init(name: .easeInEaseOut)

                controller.view.animator().alphaValue = 1
            }, completionHandler: nil)
        } else {
            controller.view.alphaValue = 1
        }
    }
    
    func dismiss(_ controller: ViewController, animated: Bool = true) {
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = Constants.dismissAnimationTimeInterval
                context.timingFunction = .init(name: .easeInEaseOut)

                controller.view.animator().alphaValue = 0
                }, completionHandler: {
                    controller.view.removeFromSuperview()
                    controller.removeFromParent()
                }
            )
        } else {
            controller.view.removeFromSuperview()
            controller.removeFromParent()
        }
    }
}
