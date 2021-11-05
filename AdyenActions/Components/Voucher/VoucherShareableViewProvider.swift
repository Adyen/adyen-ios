//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import UIKit

internal protocol AnyVoucherShareableViewProvider: Localizable {

    var style: VoucherComponentStyle { get }
    
    func provideView(with action: VoucherAction, logo: UIImage?) -> UIView
}

internal final class VoucherShareableViewProvider: AnyVoucherShareableViewProvider {

    internal let style: VoucherComponentStyle

    internal var localizationParameters: LocalizationParameters?
    
    private var logo: UIImage?
    
    private let environment: AnyAPIEnvironment

    internal init(style: VoucherComponentStyle, environment: AnyAPIEnvironment) {
        self.style = style
        self.environment = environment
    }
    
    internal func provideView(with action: VoucherAction, logo: UIImage?) -> UIView {
        self.logo = logo
        
        let view: ShareableVoucherView
        switch action {
        case let .dokuIndomaret(action):
            view = createGenericView(with: action, fields: createDokuVoucherFields(for: action))
        case let .dokuAlfamart(action):
            view = createGenericView(with: action, fields: createDokuVoucherFields(for: action))
        case let .econtextStores(action):
            view = createGenericView(with: action, fields: createEContextStoresVoucherFields(for: action))
        case let .econtextATM(action):
            view = createGenericView(with: action, fields: createEContextATMVoucherFields(for: action))
        case let .oxxo(action):
            view = createGenericView(with: action, fields: createOXXOVoucherFields(for: action))
        case let .boletoBancairoSantander(action):
            view = createBoletoView(with: action)
        case let .multibanco(action):
            view = createGenericView(with: action, fields: createMultibancoVoucherFields(for: action))
        }
        
        return view
    }
    
    private func createGenericView(
        with action: GenericVoucherAction,
        fields: [ShareableVoucherView.VoucherField]
    ) -> ShareableVoucherView {
        ShareableVoucherView(
            model: createModel(
                totalAmount: action.totalAmount,
                paymentMethodName: action.paymentMethodType.rawValue,
                reference: action.reference,
                fields: fields
            )
        )
    }
    
    private func createBoletoView(
        with boletoAction: BoletoVoucherAction
    ) -> ShareableVoucherView {
        ShareableVoucherView(
            model: createModel(
                totalAmount: boletoAction.totalAmount,
                paymentMethodName: boletoAction.paymentMethodType.rawValue,
                reference: boletoAction.reference,
                fields: createBoletoVoucherFields(for: boletoAction)
            )
        )
    }

    private func createModel(totalAmount: Amount,
                             paymentMethodName: String,
                             reference: String,
                             fields: [ShareableVoucherView.VoucherField]) -> ShareableVoucherView.Model {
        let amountString = AmountFormatter.formatted(
            amount: totalAmount.value,
            currencyCode: totalAmount.currencyCode,
            localeIdentifier: localizationParameters?.locale
        )
        let separatorTitle = localizedString(.voucherPaymentReferenceLabel, localizationParameters)
        let text = localizedString(.voucherIntroduction, localizationParameters)
        let style = ShareableVoucherView.Model.Style(backgroundColor: self.style.backgroundColor)
        
        return ShareableVoucherView.Model(
            separatorModel: .init(separatorTitle: separatorTitle),
            text: text,
            amount: amountString,
            code: reference,
            fields: fields,
            logo: logo,
            style: style
        )
    }

    private func createEContextStoresVoucherFields(for action: EContextStoresVoucherAction) -> [ShareableVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt),
         createMaskedPhoneField(with: action.maskedTelephoneNumber)]
    }

    private func createEContextATMVoucherFields(for action: EContextATMVoucherAction) -> [ShareableVoucherView.VoucherField] {
        [createCollectionInstitutionField(with: action.collectionInstitutionNumber),
         createExpirationField(with: action.expiresAt),
         createMaskedPhoneField(with: action.maskedTelephoneNumber)]
    }
    
    private func createOXXOVoucherFields(for action: OXXOVoucherAction) -> [ShareableVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt),
         createShopperReferenceField(with: action.merchantReference),
         createAlternativeReferenceField(with: action.alternativeReference)]
    }
    
    private func createMultibancoVoucherFields(for action: MultibancoVoucherAction) -> [ShareableVoucherView.VoucherField] {
        [.init(identifier: "entity", title: localizedString(.voucherEntity, localizationParameters), value: action.entity),
         createExpirationField(with: action.expiresAt),
         createShopperReferenceField(with: action.merchantReference)]
    }

    private func createDokuVoucherFields(for action: DokuVoucherAction) -> [ShareableVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt),
         createShopperNameField(with: action.shopperName),
         createMerchantField(with: action.merchantName)]
    }
    
    private func createBoletoVoucherFields(for action: BoletoVoucherAction) -> [ShareableVoucherView.VoucherField] {
        [createExpirationField(with: action.expiresAt)]
    }

    private func createExpirationField(with expiration: Date) -> ShareableVoucherView.VoucherField {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let expiration = dateFormatter.string(from: expiration)
        return ShareableVoucherView.VoucherField(identifier: "expiration",
                                                 title: localizedString(.voucherExpirationDate, localizationParameters),
                                                 value: expiration)
    }

    private func createShopperNameField(with name: String) -> ShareableVoucherView.VoucherField {
        ShareableVoucherView.VoucherField(identifier: "shopperName",
                                          title: localizedString(.voucherShopperName, localizationParameters),
                                          value: name)
    }
    
    private func createShopperReferenceField(with reference: String) -> ShareableVoucherView.VoucherField {
        ShareableVoucherView.VoucherField(identifier: "shopperReference",
                                          title: localizedString(.voucherShopperReference, localizationParameters),
                                          value: reference)
    }
    
    private func createAlternativeReferenceField(with reference: String) -> ShareableVoucherView.VoucherField {
        ShareableVoucherView.VoucherField(identifier: "alternativeReference",
                                          title: localizedString(.voucherAlternativeReference, localizationParameters),
                                          value: reference)
    }

    private func createMerchantField(with name: String) -> ShareableVoucherView.VoucherField {
        ShareableVoucherView.VoucherField(identifier: "merchant",
                                          title: localizedString(.voucherMerchantName, localizationParameters),
                                          value: name)
    }

    private func createMaskedPhoneField(with phone: String) -> ShareableVoucherView.VoucherField {
        ShareableVoucherView.VoucherField(identifier: "maskedTelephoneNumber",
                                          title: localizedString(.phoneNumberTitle, localizationParameters),
                                          value: phone)
    }

    private func createCollectionInstitutionField(with number: String) -> ShareableVoucherView.VoucherField {
        ShareableVoucherView.VoucherField(identifier: "CollectionInstitutionNumber",
                                          title: localizedString(.voucherCollectionInstitutionNumber, localizationParameters),
                                          value: number)
    }
}
