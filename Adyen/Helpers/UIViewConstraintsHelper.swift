//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

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
            base.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding.left),
            base.rightAnchor.constraint(equalTo: view.rightAnchor, constant: padding.right)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    /// Attach top, bottom, left and right anchores of this view to corespondent anchores inside specified view.
    /// IMPORTANT: both view should be in the same hierarcy.
    /// - Parameter view: Container view
    @discardableResult
    public func anchor(inside margines: UILayoutGuide, with padding: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            base.topAnchor.constraint(equalTo: margines.topAnchor, constant: padding.top),
            base.bottomAnchor.constraint(equalTo: margines.bottomAnchor, constant: padding.bottom),
            base.leftAnchor.constraint(equalTo: margines.leftAnchor, constant: padding.left),
            base.rightAnchor.constraint(equalTo: margines.rightAnchor, constant: padding.right)
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
        anchor(inside: containerView, with: UIEdgeInsets(top: insets.top,
                                                         left: insets.left,
                                                         bottom: insets.bottom,
                                                         right: insets.right))
        return containerView
    }

}
