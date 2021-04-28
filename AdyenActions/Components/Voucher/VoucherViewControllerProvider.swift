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

    internal let style: VoucherComponentStyle

    internal var localizationParameters: LocalizationParameters?

    internal weak var delegate: VoucherViewDelegate?

    internal init(style: VoucherComponentStyle) {
        self.style = style
    }

    internal func provide(with action: VoucherAction) -> UIViewController {
        switch action {
        case let .dokuIndomaret(action):
            let fields = createDokuVoucherFields(for: action)
            return createGenericViewController(with: action, fields: fields)
        case let .dokuAlfamart(action):
            let fields = createDokuVoucherFields(for: action)
            return createGenericViewController(with: action, fields: fields)
        case let .econtextStores(action):
            let fields = createEContextStoresVoucherFields(for: action)
            return createGenericViewController(with: action, fields: fields)
        case let .econtextATM(action):
            let fields = createEContextATMVoucherFields(for: action)
            return createGenericViewController(with: action, fields: fields)
        }
    }

    private func createGenericViewController(with action: GenericVoucherAction,
                                             fields: [GenericVoucherView.VoucherField]) -> UIViewController {
        let view = GenericVoucherView(model: createModel(with: action, fields: fields))
        view.delegate = delegate
        view.localizationParameters = localizationParameters
        let viewController = VoucherViewController(voucherView: view, style: style)
        view.presenter = viewController
        return viewController
    }

    private func createModel(with action: GenericVoucherAction,
                             fields: [GenericVoucherView.VoucherField]) -> GenericVoucherView.Model {
        let amountString = AmountFormatter.formatted(amount: action.totalAmount.value,
                                                     currencyCode: action.totalAmount.currencyCode)

        let logoUrl = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue,
                                              environment: .test,
                                              size: .medium)
        let separatorTitle = localizedString(.voucherPaymentReferenceLabel, localizationParameters)
        let text = localizedString(.voucherIntroduction, localizationParameters)
        let instructionTitle = localizedString(.voucherReadInstructions, localizationParameters)
        let instructionStyle = GenericVoucherView.Model.Instruction.Style()
        let instruction = GenericVoucherView.Model.Instruction(title: instructionTitle,
                                                               url: URL(string: action.instructionsUrl),
                                                               style: instructionStyle)

        let style = GenericVoucherView.Model.Style(mainButton: self.style.mainButton,
                                                   secondaryButton: self.style.secondaryButton,
                                                   backgroundColor: self.style.backgroundColor)

        let baseStyle = AbstractVoucherView.Model.Style(mainButtonStyle: self.style.mainButton,
                                                        secondaryButtonStyle: self.style.secondaryButton,
                                                        backgroundColor: self.style.backgroundColor)
        let saveAsImageCopy = localizedString(.voucherSaveImage, localizationParameters)
        let finishCopy = localizedString(.voucherFinish, localizationParameters)
        let baseModel = AbstractVoucherView.Model(separatorModel: .init(separatorTitle: separatorTitle),
                                                  saveButtonTitle: saveAsImageCopy,
                                                  doneButtonTitle: finishCopy,
                                                  style: baseStyle)
        return GenericVoucherView.Model(text: text,
                                        amount: amountString,
                                        instruction: instruction,
                                        code: action.reference,
                                        fields: fields,
                                        logoUrl: logoUrl,
                                        style: style,
                                        baseViewModel: baseModel)
    }

    private func createEContextStoresVoucherFields(for action: EContextStoresVoucherAction) -> [GenericVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt),
         createMaskedPhoneField(with: action.maskedTelephoneNumber)]
    }

    private func createEContextATMVoucherFields(for action: EContextATMVoucherAction) -> [GenericVoucherView.VoucherField] {
        [createCollectionInstitutionField(with: action.collectionInstitutionNumber),
         createExpirationField(with: action.expiresAt),
         createMaskedPhoneField(with: action.maskedTelephoneNumber)]
    }

    private func createDokuVoucherFields(for action: DokuVoucherAction) -> [GenericVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt),
         createShopperNameField(with: action.shopperName),
         createMerchantField(with: action.merchantName)]
    }

    private func createExpirationField(with expiration: Date) -> GenericVoucherView.VoucherField {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let expiration = dateFormatter.string(from: expiration)
        return GenericVoucherView.VoucherField(identifier: "expiration",
                                               title: localizedString(.voucherExpirationDate, localizationParameters),
                                               value: expiration)
    }

    private func createShopperNameField(with name: String) -> GenericVoucherView.VoucherField {
        GenericVoucherView.VoucherField(identifier: "shopperName",
                                        title: localizedString(.voucherShopperName, localizationParameters),
                                        value: name)
    }

    private func createMerchantField(with name: String) -> GenericVoucherView.VoucherField {
        GenericVoucherView.VoucherField(identifier: "merchant",
                                        title: localizedString(.voucherMerchantName, localizationParameters),
                                        value: name)
    }

    private func createMaskedPhoneField(with phone: String) -> GenericVoucherView.VoucherField {
        GenericVoucherView.VoucherField(identifier: "maskedTelephoneNumber",
                                        title: localizedString(.phoneNumberTitle, localizationParameters),
                                        value: phone)
    }

    private func createCollectionInstitutionField(with number: String) -> GenericVoucherView.VoucherField {
        GenericVoucherView.VoucherField(identifier: "CollectionInstitutionNumber",
                                        title: localizedString(.voucherCollectionInstitutionNumber, localizationParameters),
                                        value: number)
    }
}
