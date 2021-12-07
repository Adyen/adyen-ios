//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

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
    ///   - percentage: The percentage of a length of a smallest dimension.
    func round(corners: UIRectCorner, percentage: CGFloat) {
        let radius = percentage * min(base.bounds.height, base.bounds.width)
        base.adyen.round(corners: corners, radius: radius)
    }
    
    /// Apply a BezierPath mask in shape of a rounded rectangular path.
    /// - Parameters:
    ///   - corners: The corners of a rectangle to round.
    ///   - rounding: The rounding style.
    func round(corners: UIRectCorner, rounding: CornerRounding) {
        switch rounding {
        case let .fixed(value):
            base.adyen.round(corners: corners, radius: value)
        case let .percent(value):
            base.adyen.round(corners: corners, percentage: value)
        case .none:
            break
        }
    }
    
    /// Apply a radius to redraw view with a rounded corners for the layer’s background. Requires bounds clipping.
    /// - Parameters:
    ///   - radius: The radius of each corner oval.
    func round(using rounding: CornerRounding) {
        if #available(iOS 13.0, *) {
            base.layer.cornerCurve = .continuous
        }
        
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
