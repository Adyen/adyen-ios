//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif
import UIKit

// MARK: - SessionStoredPaymentMethodsDelegate

extension CheckoutCore: SessionStoredPaymentMethodsDelegate {

    package nonisolated var isSession: Bool {
        true
    }

    package var showRemovePaymentMethodButton: Bool {
        session?.showRemovePaymentMethodButton ?? false
    }

    package func disable(storedPaymentMethod: StoredPaymentMethod, dropInComponent: any AnyDropInComponent, completion: @escaping Completion<Bool>) {
        guard let session else {
            completion(false)
            return
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                try await session.disable(storedPaymentMethod: storedPaymentMethod)
                completion(true)
            } catch {
                showAlert(on: dropInComponent)
                completion(false)
            }
        }
    }

    public func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>) {
        AdyenAssertion.assertionFailure(message: "Use the new delegate method from session.")
    }
}

private extension CheckoutCore {

    func showAlert(on dropInComponent: any AnyDropInComponent) {
        let localizationParameters = (dropInComponent as? Localizable)?.localizationParameters
        let title = localizedString(.errorTitle, localizationParameters)
        let message = localizedString(.errorUnknown, localizationParameters)
        let doneTitle = localizedString(.dismissButton, localizationParameters)

        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let doneAction = UIAlertAction(title: doneTitle, style: .default)
        alertController.addAction(doneAction)

        dropInComponent.viewController.present(alertController, animated: true)
    }
}
