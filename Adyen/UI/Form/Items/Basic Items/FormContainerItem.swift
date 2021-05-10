//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item to wrap another item and provide a margin around it.
/// :nodoc:
public class FormContainerItem: FormItem {

    /// Create a new instance of FormContainerItem, that wraps `content` item with `padding`.
    /// - Parameters:
    ///   - content: The Form item to wrap.
    ///   - padding: The padding around `content`.
    ///   - identifier: The optional accessibility identifier for FormView.
    public init(content: FormItem, padding: UIEdgeInsets = .zero, identifier: String? = nil) {
        self.content = content
        self.identifier = identifier
        self.padding = padding
    }

    /// :nodoc:
    public var identifier: String?

    /// The content of container.
    public let content: FormItem

    /// The margin around content.
    public var padding: UIEdgeInsets

    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let container = FormContainerView()
        let contentView = content.build(with: builder)
        container.accessibilityIdentifier = identifier
        container.fill(with: contentView, padding: padding)
        return container
    }

    private class FormContainerView: UIView, AnyFormItemView {
        weak var delegate: FormItemViewDelegate?
        var childItemViews: [AnyFormItemView] = []

        internal func fill(with contentView: UIView, padding: UIEdgeInsets) {
            preservesSuperviewLayoutMargins = true
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            let constraints = [
                contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: padding.top),
                contentView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: padding.left),
                contentView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: padding.right),
                contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: padding.bottom)
            ]

            NSLayoutConstraint.activate(constraints)
        }
    }
}

extension FormItem {

    public func withPadding(padding: UIEdgeInsets) -> FormContainerItem {
        FormContainerItem(content: self, padding: padding)
    }

}
