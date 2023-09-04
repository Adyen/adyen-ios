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

final class VoucherShareableViewProviderMock: AnyVoucherShareableViewProvider {

    var style = VoucherComponentStyle()

    var delegate: VoucherViewDelegate?

    var localizationParameters: LocalizationParameters?

    var onProvide: ((_ action: VoucherAction) -> UIView)?

    func provideView(with action: VoucherAction, logo image: UIImage?) -> UIView {
        onProvide?(action) ?? UIView()
    }
}
