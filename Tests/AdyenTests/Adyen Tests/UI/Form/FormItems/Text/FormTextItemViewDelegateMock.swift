//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

final class FormTextItemViewDelegateMock: FormTextItemViewDelegate {
    
    var handleDidReachMaximumLength: ((_ itemView: FormTextItemView<FormTextInputItem>) -> Void)?
    func didReachMaximumLength(in itemView: FormTextItemView<some FormTextItem>) {
        handleDidReachMaximumLength?(itemView as! FormTextItemView<FormTextInputItem>)
    }
    
    var handleDidSelectReturnKey: ((_ itemView: FormTextItemView<FormTextInputItem>) -> Void)?
    func didSelectReturnKey(in itemView: FormTextItemView<some FormTextItem>) {
        handleDidSelectReturnKey?(itemView as! FormTextItemView<FormTextInputItem>)
    }
    
}
