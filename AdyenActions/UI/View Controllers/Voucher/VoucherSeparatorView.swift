//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import AdyenUI
import CoreGraphics
import QuartzCore
import UIKit

extension VoucherSeparatorView {
    internal struct Model {
        internal var separatorTitle: String
    }
}

internal final class VoucherSeparatorView: UIView {

    private lazy var leftSeparatorLayer = CALayer()

    private lazy var rightSeparatorLayer = CALayer()

    private lazy var separatorTextLayer = CATextLayer()

    private let model: Model

    private let theme: CheckoutTheme

    internal init(model: Model, theme: CheckoutTheme) {
        self.model = model
        self.theme = theme
        super.init(frame: .zero)
        buildUI()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal var rightCutoutFrame: CGRect {
        CGRect(
            origin: CGPoint(
                x: bounds.size.width - arcLayerSize.width,
                y: bounds.height / 2 - arcLayerSize.height / 2
            ),
            size: arcLayerSize
        )
    }

    private var rightSeparatorLayerFrame: CGRect {
        let xCoordinate = bounds.size.width - arcLayerSize.width - halfSeparatorBreadth - halfSeparatorLineWidth
        return CGRect(
            origin: CGPoint(
                x: xCoordinate,
                y: bounds.height / 2 - halfSeparatorLineWidth / 2
            ),
            size: CGSize(width: halfSeparatorBreadth, height: halfSeparatorLineWidth)
        )
    }

    private var leftSeparatorLayerFrame: CGRect {
        CGRect(
            origin: CGPoint(
                x: arcLayerSize.width + halfSeparatorLineWidth,
                y: bounds.height / 2 - halfSeparatorLineWidth / 2
            ),
            size: CGSize(width: halfSeparatorBreadth, height: halfSeparatorLineWidth)
        )
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

    override internal func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayout()
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        rightSeparatorLayer.frame = rightSeparatorLayerFrame
        leftSeparatorLayer.frame = leftSeparatorLayerFrame
        separatorTextLayer.frame = separatorTextLayerFrame

        separatorTextLayer.foregroundColor = theme.colors.text.cgColor
        leftSeparatorLayer.backgroundColor = theme.colors.separator.cgColor
        rightSeparatorLayer.backgroundColor = theme.colors.separator.cgColor
    }

    private func buildUI() {
        buildSeparatorLines()
    }

    private func buildSeparatorLines() {
        leftSeparatorLayer.contentsScale = UIScreen.main.scale
        rightSeparatorLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(leftSeparatorLayer)
        layer.addSublayer(rightSeparatorLayer)
        buildSeparatorTextLayer()
    }

    private func buildSeparatorTextLayer() {
        let text = model.separatorTitle
        let font = theme.elements.labels.footnote.font
        separatorTextLayer.font = font
        separatorTextLayer.fontSize = font.pointSize
        separatorTextLayer.alignmentMode = .center
        separatorTextLayer.string = text
        separatorTextLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(separatorTextLayer)
    }

    private var separatorTextLayerFrame: CGRect {
        CGRect(
            origin: CGPoint(
                x: leftSeparatorLayerFrame.maxX,
                y: bounds.height / 2 - 9
            ),
            size: CGSize(width: separatorTextLayerWidth, height: 18)
        )
    }

    private var separatorTextLayerWidth: CGFloat {
        bounds.size.width - halfSeparatorBreadth * 2 - arcLayerSize.width * 2
    }

}
