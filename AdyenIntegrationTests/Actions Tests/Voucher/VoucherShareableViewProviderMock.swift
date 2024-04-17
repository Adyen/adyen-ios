//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@testable import AdyenActions
import UIKit

internal final class VoucherShareableViewProviderMock: AnyVoucherShareableViewProvider {

    internal var style = VoucherComponentStyle()

    internal var delegate: VoucherViewDelegate?

    internal var localizationParameters: LocalizationParameters?

    internal var onProvide: ((_ action: VoucherAction) -> UIView)?

    internal func provideView(with action: VoucherAction, logo image: UIImage?) -> UIView {
        onProvide?(action) ?? UIView()
    }
}
