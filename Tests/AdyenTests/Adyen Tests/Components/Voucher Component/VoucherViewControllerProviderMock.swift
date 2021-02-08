//
//  VoucherViewControllerProviderMock.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 2/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import UIKit
import Adyen
@testable import AdyenActions

internal final class VoucherViewControllerProviderMock: AnyVoucherViewControllerProvider {

    internal var style: VoucherComponentStyle = VoucherComponentStyle()

    internal var localizationParameters: LocalizationParameters?

    internal var onProvide: ((_ action: VoucherAction) -> UIViewController)?

    internal func provide(with action: VoucherAction) -> UIViewController {
        onProvide?(action) ?? UIViewController()
    }
}
