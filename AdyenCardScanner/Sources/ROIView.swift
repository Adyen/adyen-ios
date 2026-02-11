//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Region of Interest (ROI) view.
internal class ROIView: UIView {

    // MARK: - Properties

    private var borderWidth: CGFloat = 2.0
    private var borderColor: UIColor = .white
    private var cornerRadius: CGFloat = 12.0

    // MARK: - Public

    override internal func draw(_ rect: CGRect) {
        super.draw(rect)

        // Create full view path (outer shape)
        let fullPath = UIBezierPath(rect: bounds)

        // Create the rounded rectangle "hole" covering the full view
        let holePath = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth, dy: borderWidth), cornerRadius: cornerRadius)

        // Subtract the hole from the full path
        fullPath.append(holePath)
        fullPath.usesEvenOddFillRule = true

        // Apply masking
        let maskLayer = CAShapeLayer()
        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd
        layer.mask = maskLayer

        // Create a visible border layer
        let borderLayer = CAShapeLayer()
        borderLayer.path = holePath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor // Change border color as needed
        borderLayer.lineWidth = borderWidth
        layer.addSublayer(borderLayer)
    }
}
