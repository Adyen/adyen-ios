//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// So that any `UIView` instance will inherit the `adyen` scope.
/// :nodoc:
extension UIView: AdyenCompatible {}

/// Adds helper functionality to any `UIViewController` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base: UIView {
    
    /// Apply a BezierPath mask in shape of a rounded rectangular path.
    /// - Parameters:
    ///   - corners: The corners of a rectangle to round.
    ///   - radius: The radius of each corner oval.
    func round(corners: UIRectCorner, radius: CGFloat) {
        let maskedLayer = CAShapeLayer()
        let radii = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: base.bounds, byRoundingCorners: corners, cornerRadii: radii)
        maskedLayer.path = path.cgPath
        base.layer.mask = maskedLayer
    }
    
    /// Apply a BezierPath mask in shape of a rounded rectangular path.
    /// - Parameters:
    ///   - corners: The corners of a rectangle to round.
    ///   - radius: The persent of a length of a smallest dimention.
    func round(corners: UIRectCorner, precentage: CGFloat) {
        let radius = precentage * min(base.bounds.height, base.bounds.width)
        base.adyen.round(corners: corners, radius: radius)
    }
    
    /// Apply a BezierPath mask in shape of a rounded rectangular path.
    /// - Parameters:
    ///   - corners: The corners of a rectangle to round.
    ///   - radius: The rounding style.
    func round(corners: UIRectCorner, rounding: CornerRounding) {
        switch rounding {
        case let .fixed(value):
            base.adyen.round(corners: corners, radius: value)
        case let .percent(value):
            base.adyen.round(corners: corners, precentage: value)
        case .none:
            break
        }
    }
    
    /// Apply a radius to redraw view with a rounded corners for the layer’s background. Requires bounds clipping.
    /// - Parameters:
    ///   - radius: The radius of each corner oval.
    func round(using rounding: CornerRounding) {
        switch rounding {
        case let .fixed(value):
            base.layer.cornerRadius = value
        case let .percent(value):
            let radius = value * min(base.bounds.height, base.bounds.width)
            base.layer.cornerRadius = radius
        case .none:
            base.layer.cornerRadius = 0
        }
    }
    
}
