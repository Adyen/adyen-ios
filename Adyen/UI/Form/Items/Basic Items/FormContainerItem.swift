//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item to wrap another item and provide a margin around it.
@_spi(AdyenInternal)
public class FormContainerItem: FormItem {

    public var subitems: [FormItem]

    /// Create a new instance of FormContainerItem, that wraps `content` item with `padding`.
    /// - Parameters:
    ///   - content: The Form item to wrap.
    ///   - padding: The padding around `content`.
    ///   - identifier: The optional accessibility identifier for FormView.
    public init(content: FormItem, padding: UIEdgeInsets = .zero, identifier: String? = nil) {
        self.subitems = [content]
        self.identifier = identifier
        self.padding = padding
    }

    public var identifier: String?

    /// The content of container.
    public var content: FormItem {
        subitems[0]
    }

    /// The margin around content.
    public var padding: UIEdgeInsets

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let container = FormContainerView()
        let contentView = content.build(with: builder)
        container.accessibilityIdentifier = identifier
        container.fill(with: contentView, padding: padding)
        return container
    }

    private class FormContainerView: UIView, AnyFormItemView {
        var childItemViews: [AnyFormItemView] = []

        internal func fill(with contentView: UIView, padding: UIEdgeInsets) {
            preservesSuperviewLayoutMargins = true
            addSubview(contentView)
            contentView.adyen.anchor(inside: self.layoutMarginsGuide, with: padding)
        }
        
        internal func reset() { /* Do nothing */ }
    }
}

@_spi(AdyenInternal)
extension FormItem {

    public func addingDefaultMargins() -> FormContainerItem {
        FormContainerItem(content: self, padding: .zero)
    }

}
