//
//  VoucherShareableViewProviderMock.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
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
