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

extension NSBezierPath {
    var path: CGPath {
        if #available(macOS 14, *) {
            return cgPath
        } else {
            let path = CGMutablePath()
            let componentsCount = 3
            var points = [CGPoint](repeating: .zero, count: componentsCount)

            for index in 0 ..< elementCount {
                let type = element(at: index, associatedPoints: &points)

                switch type {
                case .moveTo:
                    path.move(to: points[0])

                case .lineTo:
                    path.addLine(to: points[0])

                case .curveTo:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])

                case .closePath:
                    path.closeSubpath()

                case .cubicCurveTo, .quadraticCurveTo:
                    break

                @unknown default:
                    break
                }
            }

            return path
        }
    }
}
