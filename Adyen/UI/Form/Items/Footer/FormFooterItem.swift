//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a footer, including a submit button.
/// :nodoc:
public final class FormFooterItem: FormItem {
    
    /// Indicates the `FormFooterItemView` UI styling.
    public let style: FormFooterStyle
    
    /// :nodoc:
    public var identifier: String?
    
    /// The title of the footer.
    public var title: String?
    
    /// The title of the submit button.
    public var submitButtonTitle: String?
    
    /// The observable of the button indicator activity.
    public var showsActivityIndicator = Observable(false)
    
    /// A closure that will be invoked when the submit button is selected.
    public var submitButtonSelectionHandler: (() -> Void)?
    
    /// Initializes the footer item.
    ///
    /// - Parameter style: The `FormFooterItemView` UI style.
    public init(style: FormFooterStyle = FormFooterStyle()) {
        self.style = style
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
