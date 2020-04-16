//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a single button with a spinner.
/// :nodoc:
public final class FormButtonItem: FormItem {
    
    /// Indicates the button UI styling.
    public let style: ButtonStyle
    
    /// :nodoc:
    public var identifier: String?
    
    /// The title of the button.
    public var title: String?
    
    /// The observable of the button indicator activity.
    public var showsActivityIndicator = Observable(false)
    
    /// A closure that will be invoked when a button is selected.
    public var buttonSelectionHandler: (() -> Void)?
    
    /// Initializes the button item.
    ///
    /// - Parameter style: The `SubmitButton` UI style.
    public init(style: ButtonStyle) {
        self.style = style
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
