//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a search bar button.
@_spi(AdyenInternal)
public final class FormSearchButtonItem: FormItem {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public var subitems: [FormItem] = []
    
    /// Indicates the item's UI styling.
    public let style: ViewStyle
    
    public var identifier: String?
    
    /// The title of the button.
    @AdyenObservable(nil) public var placeholder: String?
    
    /// A closure that will be invoked when a button is selected.
    public let selectionHandler: () -> Void
    
    /// Initializes the button item.
    ///
    /// - Parameter placeholder: The search bar placeholder
    /// - Parameter style: The style of the search bar
    /// - Parameter selectionHandler: A closure that will be invoked when a button is selected.
    public init(
        placeholder: String,
        style: ViewStyle,
        identifier: String,
        selectionHandler: @escaping () -> Void
    ) {
        self.selectionHandler = selectionHandler
        self.style = style
        self.identifier = identifier
        self.placeholder = placeholder
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
