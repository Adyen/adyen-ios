//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// A form item that represents a single button with a spinner.
@_spi(AdyenInternal)
public final class FormButtonItem: FormItem {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public var subitems: [FormItem] = []

    public var style: FormButtonItemStyle

    /// Indicates the item's UI styling.
    public var buttonStyle: AdyenButtonStyle = AdyenButtonStyles.default.primary

    public var identifier: String?
    
    /// The title of the button.
    @AdyenObservable(nil) public var title: String?
    
    /// The observable of the button indicator activity.
    @AdyenObservable(false) public var showsActivityIndicator: Bool
    
    /// The observable of the button's availability status.
    @AdyenObservable(true) public var enabled: Bool
    
    /// A closure that will be invoked when a button is selected.
    public var buttonSelectionHandler: (() -> Void)?

    public init(style: FormButtonItemStyle) {
        self.style = style
    }

    /// Initializes the button item.
    ///
    /// - Parameter style: The item's UI style.
    public init(buttonStyle: AdyenButtonStyle = AdyenButtonStyle.primary(for: .default)) {
        self.buttonStyle = buttonStyle
        self.style = .init(button: .init(title: .init(font: .preferredFont(forTextStyle: .body), color: .red)))
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
