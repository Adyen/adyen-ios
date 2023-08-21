//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a single button with a spinner.
/// :nodoc:
public final class FormButtonItem: FormItem {

    /// :nodoc:
    public var subitems: [FormItem] = []
    
    /// Indicates the item's UI styling.
    public let style: FormButtonItemStyle
    
    /// :nodoc:
    public var identifier: String?
    
    /// The title of the button.
    @AdyenObservable(nil) public var title: String?
    
    /// The observable of the button indicator activity.
    @AdyenObservable(false) public var showsActivityIndicator: Bool
    
    /// The observable of the button's availability status.
    @AdyenObservable(true) public var enabled: Bool
    
    /// A closure that will be invoked when a button is selected.
    public var buttonSelectionHandler: (() -> Void)?
    
    /// Initializes the button item.
    ///
    /// - Parameter style: The item's UI style.
    public init(style: FormButtonItemStyle) {
        self.style = style
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
