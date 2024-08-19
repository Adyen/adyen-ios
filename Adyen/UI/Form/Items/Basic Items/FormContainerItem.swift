//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item to wrap another item + provide an additional margin around it.
/// It preserves the superview layout margins as well.
@_spi(AdyenInternal)
public class FormContainerItem<ContentItem: FormItem>: FormItem {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    public var subitems: [FormItem] { [content] }

    public var identifier: String?

    /// The content of container.
    public let content: ContentItem

    /// The margin around content.
    private let contentInset: UIEdgeInsets
    
    /// Create a new instance of FormContainerItem, that wraps `content` item with `padding`.
    /// - Parameters:
    ///   - content: The Form item to wrap.
    ///   - padding: The padding around `content`.
    ///   - identifier: The optional accessibility identifier for FormView.
    public init(
        content: ContentItem,
        contentInset: UIEdgeInsets = .zero,
        identifier: String? = nil
    ) {
        self.content = content
        self.identifier = identifier
        self.contentInset = contentInset
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let container = FormContainerView()
        let contentView = content.build(with: builder)
        container.accessibilityIdentifier = identifier
        container.setup(
            contentView: contentView,
            contentInset: contentInset
        )
        return container
    }
}

private class FormContainerView: UIView, AnyFormItemView {
    
    var childItemViews: [AnyFormItemView] = []

    internal func setup(contentView: UIView, contentInset: UIEdgeInsets) {
        preservesSuperviewLayoutMargins = true
        addSubview(contentView)
        
        // Converting the contentInset because of the implementation of `AdyenScope.anchor`
        let padding = UIEdgeInsets(
            top: contentInset.top,
            left: contentInset.left,
            bottom: -contentInset.bottom,
            right: -contentInset.right
        )
        
        contentView.adyen.anchor(
            inside: self.layoutMarginsGuide,
            with: padding
        )
    }
    
    internal func reset() { /* Do nothing */ }
}
