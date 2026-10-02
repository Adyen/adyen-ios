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

package final class BACSViewModel {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    private let amount: Amount?
    internal let configuration: BACSDirectDebitComponent.Configuration
    private let tracker: BACSDirectDebitComponentTrackerProtocol
    private let itemsFactory: BACSItemsFactoryProtocol
    private let onSubmit: (_ details: BACSDirectDebitDetails) -> Void

    // MARK: - State

    internal enum State {
        case idle
        case loaded
        case submitting
    }

    @Published internal private(set) var state: State = .idle

    /// The items currently displayed on the form. Populated once in `createItems()` and
    /// is the single source of truth for both the view controller and the validity checks below.
    internal private(set) var items: [any FormItem] = []

    // MARK: - Items

    internal var holderNameItem: FormTextInputItem?
    internal var bankAccountNumberItem: FormTextInputItem?
    internal var sortCodeItem: FormTextInputItem?
    internal var emailItem: FormTextInputItem?
    internal var amountConsentToggleItem: FormToggleItem?
    internal var legalConsentToggleItem: FormToggleItem?
    internal var submitButtonItem: FormButtonItem?

    // MARK: - Initializers

    package init(
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

    package func viewDidLoad() {
        tracker.sendInitialAnalytics()
        tracker.sendDidLoadEvent()
        items = createItems()
        state = .loaded
    }

    package func stopLoading() {
        state = .loaded
    }

    package func performSubmit() {
        state = .submitting

        guard isValid(), let details = makeDetails() else {
            stopLoading()
            return
        }

        onSubmit(details)
    }

    // MARK: - Private

    private func isValid() -> Bool {
        items
            .lazy
            .compactMap { $0 as? ValidatableFormItem }
            .allSatisfy { $0.isValid() }
    }

    private func createItems() -> [any FormItem] {
        holderNameItem = itemsFactory.createHolderNameItem()
        bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()
        amountConsentToggleItem = itemsFactory.createAmountConsentToggle(amount: amount)
        legalConsentToggleItem = itemsFactory.createLegalConsentToggle()

        if configuration.showsSubmitButton {
            submitButtonItem = itemsFactory.createPaymentButton { [weak self] in
                self?.performSubmit()
            }
        }

        let allItems: [(any FormItem)?] = [
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
        return allItems.compactMap { $0 }
    }

    private func makeDetails() -> BACSDirectDebitDetails? {
        guard let amountTermsAccepted = amountConsentToggleItem?.value,
              let legalTermsAccepted = legalConsentToggleItem?.value,
              amountTermsAccepted, legalTermsAccepted else {
            return nil
        }

        guard [holderNameItem, bankAccountNumberItem, sortCodeItem, emailItem]
            .compactMap({ $0 })
            .allSatisfy({ $0.isValid() }) else {
            return nil
        }

        guard let holderName = holderNameItem?.value,
              let bankAccountNumber = bankAccountNumberItem?.value,
              let sortCode = sortCodeItem?.value else {
            return nil
        }

        return BACSDirectDebitDetails(
            paymentMethod: paymentMethod,
            holderName: holderName,
            bankAccountNumber: bankAccountNumber,
            bankLocationId: sortCode,
            shopperEmail: emailItem?.value
        )
    }
}
