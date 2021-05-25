//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import CoreGraphics
import QuartzCore
import UIKit

internal class VoucherCardView: UIView {

    private lazy var containerLayer = VoucherCardLayer()

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

    internal init(model: VoucherSeparatorView.Model,
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

    override internal func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayout()
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        containerLayer.frame = containerLayerFrame
        shadowsLayer.forEach {
            $0.frame = shadowLayersFrame
            $0.shadowPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: containerLayerFrame.size), cornerRadius: 12).cgPath
        }

        drawCardCutOut()
        updateLayersStyle()
    }

    private func updateLayersStyle() {
        containerLayer.strokeColor = UIColor.Adyen.lightGray.withAlphaComponent(0.8).cgColor
        containerLayer.fillColor = UIColor.Adyen.componentBackground.cgColor
    }

    private var cornerRadius: CGFloat = 12

    private func drawCardCutOut() {
        let rightCutoutFrame = separatorView.convert(separatorView.rightCutoutFrame, to: self)
        containerLayer.drawCardCutOut(cutoutCenterY: rightCutoutFrame.midY - containerInsets.top)
    }

    private func buildUI() {
        buildContainerLayer()

        addSubview(stackView)
        stackView.adyen.anchor(inside: self, with: innerViewsInset)

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
        containerLayer.masksToBounds = true
        containerLayer.contentsScale = UIScreen.main.scale
        containerLayer.shouldRasterize = true
        containerLayer.rasterizationScale = UIScreen.main.scale

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

    private var shadowLayersFrame: CGRect {
        containerLayerFrame
    }

}
