//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import CoreGraphics
import QuartzCore
import UIKit

internal class BaseVoucherView: UIView {

    private lazy var containerLayer = CAShapeLayer()

    private lazy var shadowsLayer = [CALayer]()

    private lazy var separatorView = VoucherSeparatorView(model: model)

    private lazy var stackView: UIStackView = {
        topView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [topView, separatorView, bottomView])
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    private let topView: UIView

    private let bottomView: UIView

    private let model: VoucherSeparatorView.Model

    internal init(model: VoucherSeparatorView.Model = VoucherSeparatorView.Model(),
                  topView: UIView,
                  bottomView: UIView) {
        self.model = model
        self.topView = topView
        self.bottomView = bottomView
        super.init(frame: .zero)
        buildUI()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        containerLayer.frame = containerLayerFrame
        shadowsLayer.forEach {
            $0.frame = shadowLayersFrame
            $0.shadowPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: containerLayerFrame.size), cornerRadius: 12).cgPath
        }

        drawCutOut()
    }

    private func drawCutOut() {
        let cornerRadius: CGFloat = 12
        let cutoutRadius: CGFloat = 6

        let rightCutoutFrame = separatorView.convert(separatorView.rightCutoutFrame, to: self)
        let leftCutoutFrame = separatorView.convert(separatorView.leftCutoutFrame, to: self)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: cornerRadius))

        // Top Left corner
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: .pi,
                    endAngle: (.pi * 3) / 2,
                    clockwise: true)
        // Top border
        path.addLine(to: CGPoint(x: containerLayerFrame.width - cornerRadius, y: 0))

        // Top right corner
        path.addArc(withCenter: CGPoint(x: containerLayerFrame.width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: (.pi * 3) / 2,
                    endAngle: 0,
                    clockwise: true)

        // Right cutout
        let center = CGPoint(x: containerLayerFrame.width, y: rightCutoutFrame.midY - containerInsets.top)
        path.addLine(to: CGPoint(x: center.x, y: center.y - cutoutRadius))
        path.addArc(withCenter: center, radius: cutoutRadius, startAngle: (.pi * 3) / 2, endAngle: .pi * 0.5, clockwise: false)
        path.addLine(to: CGPoint(x: containerLayerFrame.width, y: containerLayerFrame.height - cornerRadius))

        // Right Bottom corner
        path.addArc(withCenter: CGPoint(x: containerLayerFrame.width - cornerRadius, y: containerLayerFrame.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: 0,
                    endAngle: .pi * 0.5,
                    clockwise: true)

        // Bottom border
        path.addLine(to: CGPoint(x: cornerRadius, y: containerLayerFrame.height))

        // Bottom left corner
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: containerLayerFrame.height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .pi * 0.5,
                    endAngle: .pi,
                    clockwise: true)

        // Left cutout
        let center1 = CGPoint(x: 0, y: leftCutoutFrame.midY - containerInsets.top)
        path.addLine(to: CGPoint(x: center1.x, y: center1.y + cutoutRadius))
        path.addArc(withCenter: center1, radius: cutoutRadius, startAngle: .pi * 0.5, endAngle: (.pi * 3) / 2, clockwise: false)
        path.close()

        containerLayer.path = path.cgPath
    }

    private func buildUI() {
        buildContainerLayer()

        addSubview(stackView)
        stackView.adyen.anchore(inside: self, with: innerViewsInset)

        separatorView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        bottomView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }

    private var innerViewsInset: UIEdgeInsets {
        UIEdgeInsets(top: containerInsets.top + 16,
                     left: containerInsets.left,
                     bottom: -containerInsets.bottom - 16,
                     right: -containerInsets.right)
    }

    private func buildContainerLayer() {
        containerLayer.lineWidth = 1
        containerLayer.strokeColor = UIColor(hex: 0xE6E9EB).cgColor
        containerLayer.fillColor = UIColor.Adyen.componentBackground.cgColor
        containerLayer.masksToBounds = true
        containerLayer.contentsScale = UIScreen.main.scale

        buildShadowLayers()
        layer.addSublayer(containerLayer)
    }

    private func buildShadowLayers() {
        let shadowLayer = CALayer()
        shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
        shadowLayer.shadowOpacity = 0.08
        shadowLayer.shadowRadius = 4
        shadowLayer.contentsScale = UIScreen.main.scale
        shadowsLayer.append(shadowLayer)
        layer.addSublayer(shadowLayer)
    }

    private var containerLayerFrame: CGRect {
        CGRect(x: containerInsets.left,
               y: containerInsets.top,
               width: bounds.size.width - containerInsets.left - containerInsets.right,
               height: bounds.size.height - containerInsets.top - containerInsets.bottom)
    }

    private let containerInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

    private var cardLayerFrame: CGRect {
        CGRect(x: 0,
               y: 0,
               width: containerLayer.bounds.size.width,
               height: containerLayer.bounds.size.height)
    }

    private var shadowLayersFrame: CGRect {
        containerLayerFrame
    }

}
