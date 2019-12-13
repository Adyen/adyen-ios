//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Adyen

final class FormTextItemViewDelegateMock: FormTextItemViewDelegate {

    var handleDidChangeValue: ((_ itemView: AnyFormValueItemView) -> Void)?
    func didChangeValue<T: FormValueItem>(in itemView: FormValueItemView<T>) {
        handleDidChangeValue?(itemView)
    }

    var handleDidReachMaximumLength: ((_ itemView: FormTextItemView) -> Void)?
    func didReachMaximumLength(in itemView: FormTextItemView) {
        handleDidReachMaximumLength?(itemView)
    }

    var handleDidSelectReturnKey: ((_ itemView: FormTextItemView) -> Void)?
    func didSelectReturnKey(in itemView: FormTextItemView) {
        handleDidSelectReturnKey?(itemView)
    }
    
}
