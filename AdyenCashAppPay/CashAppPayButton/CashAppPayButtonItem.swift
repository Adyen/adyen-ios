//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A form item that contains Cash App Pay's own button.
@available(iOS 13.0, *)
class CashAppPayButtonItem: FormItem {
    
    var subitems: [FormItem] = []
    
    var identifier: String?
    
    /// The observable of the button indicator activity.
    @AdyenObservable(false) public var showsActivityIndicator: Bool
    
    /// A closure that will be invoked when a button is selected.
    let selectionHandler: () -> Void
    
    init(selectionHandler: @escaping (() -> Void)) {
        self.selectionHandler = selectionHandler
    }
    
    func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

@available(iOS 13.0, *)
extension FormItemViewBuilder {
    func build(with item: CashAppPayButtonItem) -> FormItemView<CashAppPayButtonItem> {
        CashAppPayButtonItemView(item: item)
    }
}
