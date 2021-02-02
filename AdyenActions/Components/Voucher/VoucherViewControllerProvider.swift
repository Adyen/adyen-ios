//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol AnyVoucherViewControllerProvider: Component, Localizable {
    func provide(with action: VoucherAction) -> UIViewController
}

internal final class VoucherViewControllerProvider: AnyVoucherViewControllerProvider {

    internal var localizationParameters: LocalizationParameters?

    internal func provide(with action: VoucherAction) -> UIViewController {
        switch action {
        case let .dokuIndomaret(action):
            return createDokuViewController(with: action)
        case let .dokuAlfamart(action):
            return createDokuViewController(with: action)
        }
    }

    private func createDokuViewController(with action: DokuVoucherAction) -> UIViewController {
        let view = DokuVoucherView(model: createDokuModel(with: action))
        view.localizationParameters = localizationParameters
        let viewController = VoucherViewController(voucherView: view)
        view.presenter = viewController
        return viewController
    }

    private func createDokuModel(with action: DokuVoucherAction) -> DokuVoucherView.Model {
        let fields = createVoucherFields(for: action)
        let amountString = AmountFormatter.formatted(amount: action.totalAmount.value,
                                                     currencyCode: action.totalAmount.currencyCode)

        let logoUrl = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue,
                                              environment: .test,
                                              size: .medium)
        let separatorTitle = ADYLocalizedString("adyen.voucher.paymentReferenceLabel", localizationParameters)
        return DokuVoucherView.Model(title: "Amount",
                                     subtitle: amountString,
                                     code: action.reference,
                                     fields: fields,
                                     logoUrl: logoUrl,
                                     voucherSeparator: .init(separatorTitle: separatorTitle))
    }

    private func createVoucherFields(for action: DokuVoucherAction) -> [DokuVoucherView.VoucherField] {
        [createExpirationField(with: action),
         createShopperNameField(with: action),
         createMerchantField(with: action)]
    }

    private func createExpirationField(with action: DokuVoucherAction) -> DokuVoucherView.VoucherField {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let expiration = dateFormatter.string(from: action.expiresAt)
        return DokuVoucherView.VoucherField(identifier: "expiration",
                                            title: ADYLocalizedString("adyen.voucher.expirationDate", localizationParameters),
                                            value: expiration)
    }

    private func createShopperNameField(with action: DokuVoucherAction) -> DokuVoucherView.VoucherField {
        DokuVoucherView.VoucherField(identifier: "shopperName",
                                     title: ADYLocalizedString("adyen.voucher.shopperName", localizationParameters),
                                     value: action.shopperName)
    }

    private func createMerchantField(with action: DokuVoucherAction) -> DokuVoucherView.VoucherField {
        DokuVoucherView.VoucherField(identifier: "merchant",
                                     title: ADYLocalizedString("adyen.voucher.merchantName", localizationParameters),
                                     value: action.merchantName)
    }
}
