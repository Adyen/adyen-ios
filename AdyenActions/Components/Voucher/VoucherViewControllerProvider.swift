//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal protocol AnyVoucherViewControllerProvider: Localizable {

    var style: VoucherComponentStyle { get }

    var delegate: VoucherViewDelegate? { get set }

    func provide(with action: VoucherAction) -> UIViewController
}

internal final class VoucherViewControllerProvider: AnyVoucherViewControllerProvider {

    internal let style: VoucherComponentStyle

    internal var localizationParameters: LocalizationParameters?

    internal weak var delegate: VoucherViewDelegate?
    
    private let environment: AnyAPIEnvironment

    internal init(style: VoucherComponentStyle, environment: AnyAPIEnvironment) {
        self.style = style
        self.environment = environment
    }

    internal func provide(with action: VoucherAction) -> UIViewController {
        let view: GenericVoucherView
        switch action {
        case let .dokuIndomaret(action):
            view = createGenericView(with: action, fields: createDokuVoucherFields(for: action))
        case let .dokuAlfamart(action):
            view = createGenericView(with: action, fields: createDokuVoucherFields(for: action))
        case let .econtextStores(action):
            view = createGenericView(with: action, fields: createEContextStoresVoucherFields(for: action))
        case let .econtextATM(action):
            view = createGenericView(with: action, fields: createEContextATMVoucherFields(for: action))
        case let .boletoBancairoSantander(action):
            view = createBoletoView(with: action)
        }
        
        return createGenericViewController(with: view)
    }
    
    private func createGenericView(
        with action: GenericVoucherAction,
        fields: [GenericVoucherView.VoucherField]
    ) -> GenericVoucherView {
        GenericVoucherView(
            model: createModel(
                totalAmount: action.totalAmount,
                paymentMethodName: action.paymentMethodType.rawValue,
                instructionsUrl: action.instructionsUrl,
                reference: action.reference,
                shareButton: .saveImage,
                passToken: action.passCreationToken,
                fields: fields
            )
        )
    }
    
    private func createBoletoView(
        with boletoAction: BoletoVoucherAction
    ) -> GenericVoucherView {
        GenericVoucherView(
            model: createModel(
                totalAmount: boletoAction.totalAmount,
                paymentMethodName: boletoAction.paymentMethodType.rawValue,
                instructionsUrl: boletoAction.downloadUrl.absoluteString,
                reference: boletoAction.reference,
                shareButton: .download(boletoAction.downloadUrl),
                passToken: boletoAction.passCreationToken,
                fields: createBoletoVoucherfields(for: boletoAction)
            )
        )
    }

    private func createGenericViewController(with view: GenericVoucherView) -> UIViewController {
        view.delegate = delegate
        view.localizationParameters = localizationParameters
        let viewController = VoucherViewController(voucherView: view, style: style)
        view.presenter = viewController
        return viewController
    }

    // swiftlint:disable:next function_parameter_count
    private func createModel(totalAmount: Amount,
                             paymentMethodName: String,
                             instructionsUrl: String,
                             reference: String,
                             shareButton: AbstractVoucherView.Model.ShareButton,
                             passToken: String?,
                             fields: [GenericVoucherView.VoucherField]) -> GenericVoucherView.Model {
        let amountString = AmountFormatter.formatted(amount: totalAmount.value,
                                                     currencyCode: totalAmount.currencyCode)

        let logoUrl = LogoURLProvider.logoURL(withName: paymentMethodName,
                                              environment: environment,
                                              size: .medium)
        let separatorTitle = localizedString(.voucherPaymentReferenceLabel, localizationParameters)
        let text = localizedString(.voucherIntroduction, localizationParameters)
        let instructionTitle = localizedString(.voucherReadInstructions, localizationParameters)
        let instructionStyle = GenericVoucherView.Model.Instruction.Style()
        let instruction = GenericVoucherView.Model.Instruction(title: instructionTitle,
                                                               url: URL(string: instructionsUrl),
                                                               style: instructionStyle)

        let style = GenericVoucherView.Model.Style(mainButton: self.style.mainButton,
                                                   secondaryButton: self.style.secondaryButton,
                                                   backgroundColor: self.style.backgroundColor)

        let baseStyle = AbstractVoucherView.Model.Style(mainButtonStyle: self.style.mainButton,
                                                        secondaryButtonStyle: self.style.secondaryButton,
                                                        backgroundColor: self.style.backgroundColor)
        let baseModel = AbstractVoucherView.Model(
            separatorModel: .init(separatorTitle: separatorTitle),
            shareButton: shareButton,
            shareButtonTitle: localizedString(shareButtonCopy(shareButton), localizationParameters),
            doneButtonTitle: localizedString(.voucherFinish, localizationParameters),
            passToken: passToken,
            style: baseStyle
        )
        return GenericVoucherView.Model(text: text,
                                        amount: amountString,
                                        instruction: instruction,
                                        code: reference,
                                        fields: fields,
                                        logoUrl: logoUrl,
                                        style: style,
                                        baseViewModel: baseModel)
    }
    
    private func shareButtonCopy(_ button: AbstractVoucherView.Model.ShareButton) -> LocalizationKey {
        switch button {
        case .saveImage: return .voucherSaveImage
        case .download: return .boletoDownloadPdf
        }
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
    
    private func createBoletoVoucherfields(for action: BoletoVoucherAction) -> [GenericVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt)]
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
