//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

final class FormTextItemViewDelegateMock: FormTextItemViewDelegate {
    
    var handleDidChangeValue: ((_ itemView: AnyFormValueItemView) -> Void)?
    func didChangeValue<T: FormValueItem>(in itemView: FormValueItemView<T>) {
        handleDidChangeValue?(itemView)
    }
    
    var handleDidReachMaximumLength: ((_ itemView: FormTextItemView<FormTextInputItem>) -> Void)?
    func didReachMaximumLength<T: FormTextItem>(in itemView: FormTextItemView<T>) {
        handleDidReachMaximumLength?(itemView as! FormTextItemView<FormTextInputItem>)
    }
    
    var handleDidSelectReturnKey: ((_ itemView: FormTextItemView<FormTextInputItem>) -> Void)?
    func didSelectReturnKey<T: FormTextItem>(in itemView: FormTextItemView<T>) {
        handleDidSelectReturnKey?(itemView as! FormTextItemView<FormTextInputItem>)
    }
    
}
