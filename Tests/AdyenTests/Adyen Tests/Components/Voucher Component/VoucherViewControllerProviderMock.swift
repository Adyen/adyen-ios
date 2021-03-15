//
//  VoucherViewControllerProviderMock.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
@testable import AdyenActions
import UIKit

internal final class VoucherViewControllerProviderMock: AnyVoucherViewControllerProvider {

    internal var style = VoucherComponentStyle()

    internal var delegate: VoucherViewDelegate?

    internal var localizationParameters: LocalizationParameters?

    internal var onProvide: ((_ action: VoucherAction) -> UIViewController)?

    internal func provide(with action: VoucherAction) -> UIViewController {
        onProvide?(action) ?? UIViewController()
    }
}
