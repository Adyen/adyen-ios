//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

final class FormTextItemViewDelegateMock: FormTextItemViewDelegate {
    
    var handleDidReachMaximumLength: ((_ itemView: FormTextItemView<FormTextInputItem>) -> Void)?
    func didReachMaximumLength<T: FormTextItem>(in itemView: FormTextItemView<T>) {
        handleDidReachMaximumLength?(itemView as! FormTextItemView<FormTextInputItem>)
    }
    
    var handleDidSelectReturnKey: ((_ itemView: FormTextItemView<FormTextInputItem>) -> Void)?
    func didSelectReturnKey<T: FormTextItem>(in itemView: FormTextItemView<T>) {
        handleDidSelectReturnKey?(itemView as! FormTextItemView<FormTextInputItem>)
    }
    
}
