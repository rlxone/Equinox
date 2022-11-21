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

extension InteractiveLineChartCurve {
    private typealias PointPair = (CGPoint, CGPoint)
}

// MARK: - Class

public struct InteractiveLineChartCurve {
    private let points: [CGPoint]
    private var preparedBezierPath: NSBezierPath?

    // MARK: - Initializer

    public init(points: [CGPoint]) {
        self.points = points
        prepareBezierPath()
    }

    // MARK: - Public

    public var bezierPath: NSBezierPath {
        return preparedBezierPath ?? NSBezierPath()
    }

    // MARK: - Private

    private mutating func prepareBezierPath() {
        let controlPoints = calculateControlPoints(from: points)

        preparedBezierPath = NSBezierPath()
        preparedBezierPath?.move(to: points[0])

        for index in 1..<points.count {
            preparedBezierPath?.curve(
                to: points[index],
                controlPoint1: controlPoints[index - 1].0,
                controlPoint2: controlPoints[index - 1].1
            )
        }
    }

    private func calculateControlPoints(from points: [CGPoint]) -> [PointPair] {
        var result: [PointPair] = []
        let delta: CGFloat = 0.3

        for index in 1..<points.count {
            let point1 = points[index - 1]
            let point2 = points[index]
            let controlPoint1 = CGPoint(
                x: point1.x + delta * (point2.x - point1.x),
                y: point1.y + delta * (point2.y - point1.y)
            )
            let controlPoint2 = CGPoint(
                x: point2.x - delta * (point2.x - point1.x),
                y: point2.y - delta * (point2.y - point1.y)
            )
            result.append((controlPoint1, controlPoint2))
        }

        for index in 1..<points.count - 1 {
            let tempControlPoint1 = result[index - 1].1
            let tempControlPoint2 = result[index].0
            let centerPoint = points[index]

            let reflectedControlPoint1 = CGPoint(
                x: 2 * centerPoint.x - tempControlPoint1.x,
                y: 2 * centerPoint.y - tempControlPoint1.y
            )
            let reflectedControlPoint2 = CGPoint(
                x: 2 * centerPoint.x - tempControlPoint2.x,
                y: 2 * centerPoint.y - tempControlPoint2.y
            )

            result[index].0 = CGPoint(
                x: (reflectedControlPoint1.x + tempControlPoint2.x) / 2,
                y: (reflectedControlPoint1.y + tempControlPoint2.y) / 2
            )
            result[index - 1].1 = CGPoint(
                x: (reflectedControlPoint2.x + tempControlPoint1.x) / 2,
                y: (reflectedControlPoint2.y + tempControlPoint1.y) / 2
            )
        }

        return result
    }
}
