//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import Foundation

final class FormTextItemViewDelegateMock<ItemType: FormTextItem, TextViewType: FormTextItemView<ItemType>>: FormTextItemViewDelegate {
    
    var handleDidReachMaximumLength: ((_ itemView: TextViewType) -> Void)?
    func didReachMaximumLength(in itemView: FormTextItemView<some FormTextItem>) {
        handleDidReachMaximumLength?(itemView as! TextViewType)
    }
    
    var handleDidSelectReturnKey: ((_ itemView: TextViewType) -> Void)?
    func didSelectReturnKey(in itemView: FormTextItemView<some FormTextItem>) {
        handleDidSelectReturnKey?(itemView as! TextViewType)
    }
    
}
