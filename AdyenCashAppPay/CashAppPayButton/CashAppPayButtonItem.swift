//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A form item that contains Cash App Pay's own button.
@available(iOS 13.0, *)
internal class CashAppPayButtonItem: FormItem {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    internal var subitems: [FormItem] = []
    
    internal var identifier: String?
    
    /// The observable of the button indicator activity.
    @AdyenObservable(false) public var showsActivityIndicator: Bool
    
    /// A closure that will be invoked when a button is selected.
    internal let selectionHandler: () -> Void
    
    internal init(selectionHandler: @escaping (() -> Void)) {
        self.selectionHandler = selectionHandler
    }
    
    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

@available(iOS 13.0, *)
extension FormItemViewBuilder {
    internal func build(with item: CashAppPayButtonItem) -> FormItemView<CashAppPayButtonItem> {
        CashAppPayButtonItemView(item: item)
    }
}
