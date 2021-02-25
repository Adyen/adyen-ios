//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol AnyVoucherViewControllerProvider: Component, Localizable {

    var style: VoucherComponentStyle { get }

    var delegate: VoucherViewDelegate? { get set }

    func provide(with action: VoucherAction) -> UIViewController
}

internal final class VoucherViewControllerProvider: AnyVoucherViewControllerProvider {

    internal var style: VoucherComponentStyle

    internal var localizationParameters: LocalizationParameters?

    internal weak var delegate: VoucherViewDelegate?

    internal init(style: VoucherComponentStyle) {
        self.style = style
    }

    internal func provide(with action: VoucherAction) -> UIViewController {
        switch action {
        case let .dokuIndomaret(action):
            return createDokuViewController(with: action)
        case let .dokuAlfamart(action):
            return createDokuViewController(with: action)
        }
    }

    private func createDokuViewController(with action: GenericVoucherAction) -> UIViewController {
        let view = DokuVoucherView(model: createDokuModel(with: action))
        view.delegate = delegate
        view.localizationParameters = localizationParameters
        let viewController = VoucherViewController(voucherView: view)
        view.presenter = viewController
        return viewController
    }

    private func createDokuModel(with action: GenericVoucherAction) -> DokuVoucherView.Model {
        let fields = createVoucherFields(for: action)
        let amountString = AmountFormatter.formatted(amount: action.totalAmount.value,
                                                     currencyCode: action.totalAmount.currencyCode)

        let logoUrl = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue,
                                              environment: .test,
                                              size: .medium)
        let separatorTitle = ADYLocalizedString("adyen.voucher.paymentReferenceLabel", localizationParameters)
        let text = ADYLocalizedString("adyen.voucher.introduction", localizationParameters)
        let instructionTitle = ADYLocalizedString("adyen.voucher.readInstructions", localizationParameters)
        let instructionStyle = DokuVoucherView.Model.Instruction.Style()
        let instruction = DokuVoucherView.Model.Instruction(title: instructionTitle,
                                                            url: URL(string: action.instructionsUrl),
                                                            style: instructionStyle)

        let style = DokuVoucherView.Model.Style(mainButton: self.style.mainButton,
                                                secondaryButton: self.style.secondaryButton,
                                                backgroundColor: self.style.backgroundColor)

        let baseStyle = AbstractVoucherView.Model.Style(mainButtonStyle: self.style.mainButton,
                                                        secondaryButtonStyle: self.style.secondaryButton,
                                                        backgroundColor: self.style.backgroundColor)
        let saveAsImageCopy = ADYLocalizedString("adyen.voucher.saveImage", localizationParameters)
        let finishCopy = ADYLocalizedString("adyen.voucher.finish", localizationParameters)
        let baseModel = AbstractVoucherView.Model(separatorModel: .init(separatorTitle: separatorTitle),
                                                  saveButtonTitle: saveAsImageCopy,
                                                  doneButtonTitle: finishCopy,
                                                  style: baseStyle)
        return DokuVoucherView.Model(text: text,
                                     amount: amountString,
                                     instruction: instruction,
                                     code: action.reference,
                                     fields: fields,
                                     logoUrl: logoUrl,
                                     style: style,
                                     baseViewModel: baseModel)
    }

    private func createVoucherFields(for action: GenericVoucherAction) -> [DokuVoucherView.VoucherField] {
        [createExpirationField(with: action),
         createShopperNameField(with: action),
         createMerchantField(with: action)]
    }

    private func createExpirationField(with action: GenericVoucherAction) -> DokuVoucherView.VoucherField {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let expiration = dateFormatter.string(from: action.expiresAt)
        return DokuVoucherView.VoucherField(identifier: "expiration",
                                            title: ADYLocalizedString("adyen.voucher.expirationDate", localizationParameters),
                                            value: expiration)
    }

    private func createShopperNameField(with action: GenericVoucherAction) -> DokuVoucherView.VoucherField {
        DokuVoucherView.VoucherField(identifier: "shopperName",
                                     title: ADYLocalizedString("adyen.voucher.shopperName", localizationParameters),
                                     value: action.shopperName)
    }

    private func createMerchantField(with action: GenericVoucherAction) -> DokuVoucherView.VoucherField {
        DokuVoucherView.VoucherField(identifier: "merchant",
                                     title: ADYLocalizedString("adyen.voucher.merchantName", localizationParameters),
                                     value: action.merchantName)
    }
}
