//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import CoreGraphics
import QuartzCore
import UIKit

extension VoucherSeparatorView {
    internal struct Model {
        internal var separatorTitle: String? = "Payment code"

        internal var separatorTitlestyle = TextStyle(font: .systemFont(ofSize: 13),
                                                     color: UIColor(hex: 0x00112C),
                                                     textAlignment: .center)
    }
}

internal final class VoucherSeparatorView: UIView {

    private lazy var leftSeparatorLayer = CALayer()

    private lazy var rightSeparatorLayer = CALayer()

    private lazy var separatorTextLayer = CATextLayer()

    private lazy var leftHalfCircleLayer = CALayer()

    private lazy var rightHalfCircleLayer = CALayer()

    private let model: Model

    internal init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        buildUI()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var rightHalfCircleLayerFrame: CGRect {
        CGRect(origin: CGPoint(x: 0,
                               y: bounds.height / 2 - arcLayerSize.height / 2),
               size: arcLayerSize)
    }

    private var leftHalfCircleLayerFrame: CGRect {
        CGRect(origin: CGPoint(x: bounds.size.width - arcLayerSize.width,
                               y: bounds.height / 2 - arcLayerSize.height / 2),
               size: arcLayerSize)
    }

    private var rightSeparatorLayerFrame: CGRect {
        let xCoordinate = bounds.size.width - arcLayerSize.width - halfSeparatorBreadth
        return CGRect(origin: CGPoint(x: xCoordinate,
                                      y: bounds.height / 2 - halfSeparatorLineWidth / 2),
                      size: CGSize(width: halfSeparatorBreadth, height: halfSeparatorLineWidth))
    }

    private var leftSeparatorLayerFrame: CGRect {
        CGRect(origin: CGPoint(x: arcLayerSize.width,
                               y: bounds.height / 2 - halfSeparatorLineWidth / 2),
               size: CGSize(width: halfSeparatorBreadth, height: halfSeparatorLineWidth))
    }

    private var halfSeparatorBreadth: CGFloat {
        (bounds.size.width / 2 - arcLayerSize.width) * 0.55
    }

    private let halfSeparatorLineWidth: CGFloat = 1

    private var arcLayerSize: CGSize {
        CGSize(width: arcSize.width, height: arcSize.height)
    }

    private let archLineWidth: CGFloat = 1

    private var arcSize: CGSize {
        CGSize(width: 6, height: 12)
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        rightHalfCircleLayer.frame = rightHalfCircleLayerFrame
        leftHalfCircleLayer.frame = leftHalfCircleLayerFrame

        rightSeparatorLayer.frame = rightSeparatorLayerFrame
        leftSeparatorLayer.frame = leftSeparatorLayerFrame
        separatorTextLayer.frame = separatorTextLayerFrame
    }

    private func buildUI() {
        buildRightHalfCircle()
        buildLeftHalfCircle()
        buildSeparatorLines()
    }

    private func buildSeparatorLines() {
        leftSeparatorLayer.backgroundColor = UIColor(hex: 0xE6E9EB).cgColor
        rightSeparatorLayer.backgroundColor = UIColor(hex: 0xE6E9EB).cgColor
        leftSeparatorLayer.contentsScale = UIScreen.main.scale
        rightSeparatorLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(leftSeparatorLayer)
        layer.addSublayer(rightSeparatorLayer)
        buildSeparatorTextLayer()
    }

    private func buildSeparatorTextLayer() {
        guard let text = model.separatorTitle else { return }
        let style = model.separatorTitlestyle
        separatorTextLayer.font = style.font
        separatorTextLayer.fontSize = style.font.pointSize
        separatorTextLayer.foregroundColor = style.color.cgColor
        separatorTextLayer.backgroundColor = UIColor.Adyen.componentBackground.cgColor
        separatorTextLayer.alignmentMode = style.textAlignment.adyen.caAlignmentMode
        separatorTextLayer.string = text
        separatorTextLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(separatorTextLayer)
    }

    private var separatorTextLayerFrame: CGRect {
        CGRect(origin: CGPoint(x: leftSeparatorLayerFrame.maxX,
                               y: bounds.height / 2 - 9),
               size: CGSize(width: separatorTextLayerWidth, height: 18))
    }

    private var separatorTextLayerWidth: CGFloat {
        bounds.size.width - halfSeparatorBreadth * 2 - arcLayerSize.width * 2
    }

    private func buildRightHalfCircle() {
        let center = CGPoint(x: 0, y: arcLayerSize.height / 2)
        rightHalfCircleLayer = buildHalfCirclLayer(clockwise: false, center: center)
        layer.addSublayer(rightHalfCircleLayer)
    }

    private func buildLeftHalfCircle() {
        let center = CGPoint(x: arcLayerSize.width, y: arcLayerSize.height / 2)
        leftHalfCircleLayer = buildHalfCirclLayer(clockwise: true, center: center)
        layer.addSublayer(leftHalfCircleLayer)
    }

    private func buildHalfCirclLayer(clockwise: Bool, center: CGPoint) -> CALayer {
        let path = UIBezierPath(arcCenter: center,
                                radius: arcSize.width,
                                startAngle: CGFloat.pi / 2,
                                endAngle: (CGFloat.pi * 3) / 2,
                                clockwise: clockwise)

        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor(hex: 0xE6E9EB).cgColor
        shapeLayer.strokeColor = UIColor(hex: 0xF8F9F9).cgColor
        shapeLayer.lineWidth = archLineWidth
        shapeLayer.contentsScale = UIScreen.main.scale

        return shapeLayer
    }

}
