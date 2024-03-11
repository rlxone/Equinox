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

public protocol InteractiveLineChartDelegate: AnyObject {
    func progressDidChange(progress: CGFloat)
    func progressTitle(progress: CGFloat) -> String
}

// MARK: - Enums, Structs

extension InteractiveLineChart {
    public struct ChartData {
        let bottomText: String
        let value: CGFloat
        
        public init(bottomText: String, value: CGFloat) {
            self.bottomText = bottomText
            self.value = value
        }
    }
    
    public struct Style {
        let lineColor: NSColor
        let chartColor: NSColor
        let bottomFont: NSFont
        let bottomColor: NSColor
        let progressFont: NSFont
        let progressColor: NSColor
        let progressLineColor: NSColor
        
        public init(
            lineColor: NSColor,
            chartColor: NSColor,
            bottomFont: NSFont,
            bottomColor: NSColor,
            progressFont: NSFont,
            progressColor: NSColor,
            progressLineColor: NSColor
        ) {
            self.lineColor = lineColor
            self.chartColor = chartColor
            self.bottomFont = bottomFont
            self.bottomColor = bottomColor
            self.progressFont = progressFont
            self.progressColor = progressColor
            self.progressLineColor = progressLineColor
        }
    }
    
    private enum Constants {
        static let lineWidth: CGFloat = 1
        static let progressLineWidth: CGFloat = 3
        static let progressLineTextWidth: CGFloat = 30
        static let chartLineWidth: CGFloat = 3
        static let chartOffset: CGFloat = 0.16
    }
}

// MARK: - Class

public final class InteractiveLineChart: View {
    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Life Cycle
    
    public override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        drawVerticalLines(for: context)
        drawHorizontalLine(for: context)
        drawBottomText(for: context)
        drawChartCurve(for: context)
        drawProgressLine(for: context)
        drawProgressText(for: context)
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        let clickRecognizer = NSClickGestureRecognizer()
        clickRecognizer.numberOfClicksRequired = 1
        clickRecognizer.numberOfTouchesRequired = 1
        clickRecognizer.target = self
        clickRecognizer.action = #selector(handleClickRecognizer(_:))
        
        let panRecognizer = NSPanGestureRecognizer()
        panRecognizer.numberOfTouchesRequired = 1
        panRecognizer.target = self
        panRecognizer.action = #selector(handlePanRecognizer(_:))
        
        addGestureRecognizer(clickRecognizer)
        addGestureRecognizer(panRecognizer)
    }
    
    // MARK: - Public
    
    public weak var delegate: InteractiveLineChartDelegate?
    
    public var chartData: [ChartData]? {
        didSet {
            needsDisplay = true
        }
    }
    
    public var style: Style? {
        didSet {
            needsDisplay = true
        }
    }
    
    public var chartInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            needsDisplay = true
        }
    }
    
    public var progress: CGFloat = 0 {
        didSet {
            needsDisplay = true
        }
    }
    
    // MARK: - Private
    
    private func drawVerticalLines(for context: CGContext) {
        guard
            let chartData = chartData,
            let style = style
        else {
            return
        }
        
        let chartParts = chartData.count
        let usefulWidth = bounds.width - chartInsets.left - chartInsets.right
        let partWidth = usefulWidth / CGFloat(chartParts - 1)
        let verticalLinesCount = chartParts
        let lineHeight = bounds.height - chartInsets.top - chartInsets.bottom
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(Constants.lineWidth)
        context.setFillColor(style.lineColor.cgColor)
        
        for index in 0..<verticalLinesCount {
            let offsetX = chartInsets.left + CGFloat(index) * partWidth
            let offsetY = chartInsets.top
            
            let linePath = NSBezierPath(
                roundedRect: .init(
                    x: offsetX,
                    y: offsetY,
                    width: Constants.lineWidth,
                    height: lineHeight
                ),
                xRadius: Constants.lineWidth / 2,
                yRadius: Constants.lineWidth / 2
            )
            context.addPath(linePath.path)
            context.fillPath()
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.bottomFont,
                .foregroundColor: style.bottomColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let bottomText = chartData[index].bottomText as NSString
            let bottomTextRect = NSRect(
                x: offsetX - partWidth,
                y: 0,
                width: partWidth * 2,
                height: style.bottomFont.pointSize + 1
            )
            bottomText.draw(in: bottomTextRect, withAttributes: attributes)
        }
    }
    
    private func drawHorizontalLine(for context: CGContext) {
        guard
            let chartData = chartData,
            let style = style
        else {
            return
        }
        
        let usefulWidth = bounds.width - chartInsets.left - chartInsets.right
        let fullLineHeight = bounds.height - chartInsets.top - chartInsets.bottom
        let lineHeight = fullLineHeight - fullLineHeight * Constants.chartOffset
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(Constants.lineWidth)
        context.setFillColor(style.lineColor.cgColor)
        
        let maxChartValue = chartData.max { $0.value < $1.value }?.value ?? 0
        let minChartValue = chartData.min { $0.value < $1.value }?.value ?? 0
        
        let offsetPercent = 1 - abs(maxChartValue) / (abs(maxChartValue) + abs(minChartValue))
        
        let linePath = NSBezierPath(
            roundedRect: .init(
                x: chartInsets.left,
                y: chartInsets.bottom + Constants.chartOffset / 2 * fullLineHeight + lineHeight * offsetPercent,
                width: usefulWidth,
                height: Constants.lineWidth
            ),
            xRadius: Constants.lineWidth / 2,
            yRadius: Constants.lineWidth / 2
        )
        context.addPath(linePath.path)
        context.fillPath()
    }
    
    private func drawBottomText(for context: CGContext) {
        guard
            let chartData = chartData,
            let style = style
        else {
            return
        }
        
        let chartParts = chartData.count
        let usefulWidth = bounds.width - chartInsets.left - chartInsets.right
        let partWidth = usefulWidth / CGFloat(chartParts - 1)
        let verticalLinesCount = chartParts
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(Constants.lineWidth)
        context.setFillColor(style.lineColor.cgColor)
        
        for index in 0..<verticalLinesCount {
            let offsetX = chartInsets.left + CGFloat(index) * partWidth
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.bottomFont,
                .foregroundColor: style.bottomColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let bottomText = chartData[index].bottomText as NSString
            let bottomTextRect = NSRect(
                x: offsetX - partWidth,
                y: 0,
                width: partWidth * 2,
                height: style.bottomFont.pointSize + 1
            )
            bottomText.draw(in: bottomTextRect, withAttributes: attributes)
        }
    }
    
    private func drawProgressLine(for context: CGContext) {
        guard let style = style else {
            return
        }
        
        let lineHeight = bounds.height - chartInsets.top - chartInsets.bottom
        
        context.setLineWidth(Constants.progressLineWidth)
        context.setFillColor(style.progressLineColor.cgColor)
        
        let usefulWidth = bounds.width - chartInsets.left - chartInsets.right
        let lineOffsetX = chartInsets.left + usefulWidth * progress - Constants.progressLineWidth / 2
        
        let linePath = NSBezierPath(
            roundedRect: .init(
                x: lineOffsetX,
                y: chartInsets.top,
                width: Constants.progressLineWidth,
                height: lineHeight
            ),
            xRadius: Constants.progressLineWidth / 2,
            yRadius: Constants.progressLineWidth / 2
        )
        
        context.addPath(linePath.path)
        context.fillPath()
    }
    
    private func drawProgressText(for context: CGContext) {
        guard
            let delegate = delegate,
            let style = style
        else {
            return
        }
        
        let usefulWidth = bounds.width - chartInsets.left - chartInsets.right
        let lineOffsetX = chartInsets.left + usefulWidth * progress - Constants.progressLineWidth / 2
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.progressFont,
            .foregroundColor: style.progressColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let progressTextOffsetY = bounds.height - chartInsets.bottom + 4
        
        let progressTextRect = NSRect(
            x: lineOffsetX - Constants.progressLineTextWidth / 2 + Constants.lineWidth / 2,
            y: progressTextOffsetY,
            width: Constants.progressLineTextWidth,
            height: style.progressFont.pointSize + 1
        )
        let progressText = delegate.progressTitle(progress: progress) as NSString
        progressText.draw(in: progressTextRect, withAttributes: attributes)
    }
    
    private func drawChartCurve(for context: CGContext) {
        guard
            let style = style,
            let chartData = chartData
        else {
            return
        }
        
        var points: [CGPoint] = []
        
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setLineWidth(Constants.chartLineWidth)
        context.setStrokeColor(style.chartColor.cgColor)
        
        let chartParts = chartData.count
        let usefulWidth = bounds.width - chartInsets.left - chartInsets.right
        let partWidth = usefulWidth / CGFloat(chartParts - 1)
        let lineHeight = bounds.height - chartInsets.top - chartInsets.bottom
        
        let maxChartValue = chartData.max { $0.value < $1.value }?.value ?? 0
        let minChartValue = chartData.min { $0.value < $1.value }?.value ?? 0
        
        for (index, data) in chartData.enumerated() {
            let offsetX = chartInsets.left + CGFloat(index) * partWidth
            let totalLength = abs(maxChartValue) + abs(minChartValue)
            let offsetPercent = 1 - abs(data.value / totalLength - abs(maxChartValue) / totalLength)
            let chartHeightWithOffset = lineHeight * (1 - Constants.chartOffset)
            let offsetY = chartInsets.top + lineHeight * Constants.chartOffset / 2 + offsetPercent * (chartHeightWithOffset)
            
            points.append(.init(x: offsetX, y: offsetY))
        }
        
        let path = InteractiveLineChartCurve(points: points).bezierPath
        context.addPath(path.path)
        
        context.strokePath()
    }
    
    private func handleProgress(for recognizer: NSGestureRecognizer) {
        let location = recognizer.location(in: self)
        if location.x <= chartInsets.left {
            self.progress = 0
        } else if location.x >= bounds.width - chartInsets.left {
            self.progress = 1
        } else {
            let offsetX = location.x - chartInsets.left
            let progress = offsetX / (bounds.width - chartInsets.left - chartInsets.right)
            self.progress = progress
        }
        delegate?.progressDidChange(progress: progress)
    }
    
    @objc
    private func handleClickRecognizer(_ recognizer: NSClickGestureRecognizer) {
        handleProgress(for: recognizer)
    }
    
    @objc
    private func handlePanRecognizer(_ recognizer: NSPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            NSCursor.resizeLeftRight.set()
        
        case .changed:
            NSCursor.resizeLeftRight.set()
            handleProgress(for: recognizer)
            
        default:
            NSCursor.arrow.set()
        }
    }
}
