//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation

// swiftlint:disable:next type_name
internal struct StoredPaymentMethodManagementPresentationMapper {

    private let localizationParameters: LocalizationParameters?
    private let logoURLProvider: LogoURLProvider

    internal init(localizationParameters: LocalizationParameters?, logoURLProvider: LogoURLProvider) {
        self.localizationParameters = localizationParameters
        self.logoURLProvider = logoURLProvider
    }

    internal func sections(from paymentMethods: [any StoredPaymentMethod]) -> [StoredPaymentMethodManagementSection] {
        let items = paymentMethods.map(item(from:))
        let cards = items.filter { sectionKind(for: $0.paymentMethod) == .cards }
        let other = items.filter { sectionKind(for: $0.paymentMethod) == .other }

        return [
            cards.isEmpty ? nil : StoredPaymentMethodManagementSection(kind: .cards, items: cards),
            other.isEmpty ? nil : StoredPaymentMethodManagementSection(kind: .other, items: other)
        ].compactMap { $0 }
    }

    private func removalActionTitle(for paymentMethod: any StoredPaymentMethod) -> String {
        localizedString(
            .storedPaymentMethodManagementRemoveConfirmationAction,
            localizationParameters,
            removalTitle(for: paymentMethod)
        )
    }

    private func item(from paymentMethod: any StoredPaymentMethod) -> StoredPaymentMethodManagementItem {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)

        return StoredPaymentMethodManagementItem(
            paymentMethod: paymentMethod,
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            logoURL: logoURLProvider.logoURL(withName: displayInformation.logoName),
            accessibilityLabel: displayInformation.accessibilityLabel,
            removalActionTitle: removalActionTitle(for: paymentMethod)
        )
    }

    private func sectionKind(for paymentMethod: any StoredPaymentMethod) -> StoredPaymentMethodManagementSection.Kind {
        switch paymentMethod {
        case is StoredCardPaymentMethod, is StoredBCMCPaymentMethod:
            .cards
        default:
            .other
        }
    }

    private func removalTitle(for paymentMethod: any StoredPaymentMethod) -> String {
        switch paymentMethod {
        case let card as StoredCardPaymentMethod:
            return cardRemovalTitle(name: card.name, lastFour: card.lastFour)
        case let card as StoredBCMCPaymentMethod:
            return cardRemovalTitle(name: card.name, lastFour: card.lastFour)
        case let ach as StoredACHDirectDebitPaymentMethod:
            return cardRemovalTitle(name: ach.name, lastFour: String(ach.bankAccountNumber.suffix(4)))
        default:
            return paymentMethod.name
        }
    }

    private func cardRemovalTitle(name: String, lastFour: String) -> String {
        "\(name) \(String.Adyen.securedString)\(lastFour)"
    }
}
