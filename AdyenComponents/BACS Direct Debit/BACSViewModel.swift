//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormTextInputItem
#endif
import Foundation

internal final class BACSViewModel {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    private let amount: Amount?
    internal let configuration: BACSDirectDebitComponent.Configuration
    private let tracker: BACSDirectDebitComponentTrackerProtocol
    private let itemsFactory: BACSItemsFactoryProtocol
    private let onSubmit: (_ details: BACSDirectDebitDetails) -> Void

    // MARK: - State

    @Published internal private(set) var items: [(any FormItem)?] = []
    @Published internal private(set) var shouldShowValidation = false

    // MARK: - Items

    internal var holderNameItem: FormTextInputItem?
    internal var bankAccountNumberItem: FormTextInputItem?
    internal var sortCodeItem: FormTextInputItem?
    internal var emailItem: FormTextInputItem?
    internal var amountConsentToggleItem: FormToggleItem?
    internal var legalConsentToggleItem: FormToggleItem?
    internal var submitButtonItem: FormButtonItem?

    // MARK: - Initializers

    internal init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        amount: Amount?,
        configuration: BACSDirectDebitComponent.Configuration,
        tracker: BACSDirectDebitComponentTrackerProtocol,
        itemsFactory: BACSItemsFactoryProtocol,
        onSubmit: @escaping (_ details: BACSDirectDebitDetails) -> Void
    ) {
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.configuration = configuration
        self.tracker = tracker
        self.itemsFactory = itemsFactory
        self.onSubmit = onSubmit
    }

    // MARK: - Internal

    internal func viewDidLoad() {
        tracker.sendInitialAnalytics()
        tracker.sendDidLoadEvent()
        items = createItems()
    }

    internal func stopLoading() {
        submitButtonItem?.showsActivityIndicator = false
    }

    internal func submit() {
        startLoading()

        guard validateForm() else {
            stopLoading()
            return
        }

        guard let holderName = holderNameItem?.value,
              let bankAccountNumber = bankAccountNumberItem?.value,
              let sortCode = sortCodeItem?.value else {
            stopLoading()
            return
        }

        let details = BACSDirectDebitDetails(
            paymentMethod: paymentMethod,
            holderName: holderName,
            bankAccountNumber: bankAccountNumber,
            bankLocationId: sortCode
        )
        onSubmit(details)
    }

    // MARK: - Private

    private func startLoading() {
        submitButtonItem?.showsActivityIndicator = true
    }

    private func createItems() -> [(any FormItem)?] {
        holderNameItem = itemsFactory.createHolderNameItem()
        bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()
        amountConsentToggleItem = itemsFactory.createAmountConsentToggle(amount: amount)
        legalConsentToggleItem = itemsFactory.createLegalConsentToggle()

        if configuration.showsSubmitButton {
            submitButtonItem = itemsFactory.createPaymentButton { [weak self] in
                self?.submit()
            }
        }

        return [
            holderNameItem,
            bankAccountNumberItem,
            sortCodeItem,
            emailItem,
            FormSpacerItem(numberOfSpaces: 2),
            amountConsentToggleItem,
            FormSpacerItem(numberOfSpaces: 1),
            legalConsentToggleItem,
            FormSpacerItem(numberOfSpaces: 2),
            submitButtonItem,
            FormSpacerItem(numberOfSpaces: 1)
        ]
    }

    private func validateForm() -> Bool {
        shouldShowValidation = true

        guard let amountTermsAccepted = amountConsentToggleItem?.value,
              let legalTermsAccepted = legalConsentToggleItem?.value,
              amountTermsAccepted, legalTermsAccepted else {
            return false
        }

        return [
            holderNameItem,
            bankAccountNumberItem,
            sortCodeItem,
            emailItem
        ].compactMap { $0 }
            .allSatisfy { $0.isValid() }
    }
}
