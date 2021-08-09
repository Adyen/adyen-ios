//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import AdyenNetworking

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
/// :nodoc:
extension AdyenScope where Base: UIView {

    /// Attach top, bottom, left and right anchores of this view to corespondent anchores inside specified view.
    /// IMPORTANT: both view should be in the same hierarcy.
    /// - Parameter view: Container view
    @discardableResult
    public func anchor(inside view: UIView, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            base.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
            base.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding.bottom),
            base.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
            base.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: padding.right)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    /// Attach top, bottom, left and right anchors of this view to corresponding anchors inside specified view.
    /// IMPORTANT: both views should be in the same hierarcy.
    /// - Parameter view: Container view
    @discardableResult
    public func anchor(inside margins: UILayoutGuide, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            base.topAnchor.constraint(equalTo: margins.topAnchor, constant: padding.top),
            base.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: padding.bottom),
            base.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: padding.left),
            base.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: padding.right)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    /// Wrap the view inside a container view with certain edge insets
    ///
    /// - Parameter insets: The insets inside the container view.
    public func wrapped(with insets: UIEdgeInsets = .zero) -> UIView {
        let containerView = UIView()
        containerView.addSubview(base)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        base.translatesAutoresizingMaskIntoConstraints = false
        anchor(inside: containerView, with: insets)
        return containerView
    }

}
