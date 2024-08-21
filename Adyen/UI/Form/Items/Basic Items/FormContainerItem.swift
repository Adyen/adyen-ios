//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Simple form item to wrap another item and provide padding around it.
@_spi(AdyenInternal)
public class FormContainerItem<ContentItem: FormItem>: FormItem {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    public var subitems: [FormItem] { [content] }

    public var identifier: String?

    /// The content of container.
    public let content: ContentItem

    /// The margin around content.
    private let padding: UIEdgeInsets?
    
    /// Create a new instance of FormContainerItem, that wraps `content` item with `padding`.
    ///
    /// - Parameters:
    ///   - content: The Form item to wrap.
    ///   - padding: The padding around `content`.
    ///   - identifier: The optional accessibility identifier for FormView.
    public init(
        content: ContentItem,
        padding: UIEdgeInsets? = nil,
        identifier: String? = nil
    ) {
        self.content = content
        self.padding = padding
        self.identifier = identifier
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let container = FormContainerItemView()
        let contentView = content.build(with: builder)
        container.accessibilityIdentifier = identifier
        container.setup(
            contentView: contentView,
            padding: padding
        )
        return container
    }
}

// MARK: - FormContainerItemView

private class FormContainerItemView: UIView, AnyFormItemView {
    
    var childItemViews: [AnyFormItemView] = []

    internal func setup(contentView: UIView, padding: UIEdgeInsets?) {
        preservesSuperviewLayoutMargins = true
        addSubview(contentView)
        
        if let padding {
            // Converting the contentInset because of the implementation of `AdyenScope.anchor`
            let adjustedPadding = UIEdgeInsets(
                top: padding.top,
                left: padding.left,
                bottom: -padding.bottom,
                right: -padding.right
            )
            
            contentView.adyen.anchor(
                inside: self,
                with: adjustedPadding
            )
        } else {
            contentView.adyen.anchor(
                inside: self.layoutMarginsGuide
            )
        }
    }
    
    internal func reset() { /* Do nothing */ }
}

// MARK: - Convenience extension

@_spi(AdyenInternal)
public extension FormItem {
    
    /// Adds padding around the form item
    ///
    /// If no padding is provided it uses the superview layout margins to specify the amount of padding around the item
    ///
    /// - Parameters:
    ///   - padding: The optional fixed padding to apply
    ///
    /// - Returns: A ``FormContainerItem`` wrapping `self`
    func padding(_ padding: UIEdgeInsets? = nil) -> FormContainerItem<Self> {
        FormContainerItem(content: self, padding: padding, identifier: nil)
    }
}
