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

@MainActor
package final class BACSViewModel {

    // MARK: - Properties

    private let paymentMethod: BACSDirectDebitPaymentMethod
    internal let configuration: BACSDirectDebitConfiguration
    private let tracker: BACSDirectDebitComponentTrackerProtocol
    private let itemsFactory: BACSItemsFactoryProtocol
    private let onSubmit: (_ details: BACSDirectDebitDetails) -> Void

    // MARK: - State

    internal enum State {
        case idle
        case invalid
        case submitting
    }

    @Published internal private(set) var state: State = .idle

    /// The items currently displayed on the form. Populated once in `createItems()` and
    /// is the single source of truth for both the view controller and the validity checks below.
    internal private(set) lazy var items: [any FormItem] = createItems()

    // MARK: - Items

    internal let holderNameItem: FormTextInputItem
    internal let bankAccountNumberItem: FormTextInputItem
    internal let sortCodeItem: FormTextInputItem
    internal let emailItem: FormTextInputItem
    internal let amountConsentToggleItem: FormToggleItem
    internal let legalConsentToggleItem: FormToggleItem
    internal private(set) lazy var submitButtonItem: FormButtonItem? = createSubmitButtonItem()

    // MARK: - Initializers

    package init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        amount: Amount?,
        configuration: BACSDirectDebitConfiguration,
        tracker: BACSDirectDebitComponentTrackerProtocol,
        itemsFactory: BACSItemsFactoryProtocol,
        onSubmit: @escaping (_ details: BACSDirectDebitDetails) -> Void
    ) {
        self.paymentMethod = paymentMethod
        self.configuration = configuration
        self.tracker = tracker
        self.itemsFactory = itemsFactory
        self.onSubmit = onSubmit

        self.holderNameItem = itemsFactory.createHolderNameItem()
        self.bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        self.sortCodeItem = itemsFactory.createSortCodeItem()
        self.emailItem = itemsFactory.createEmailItem()
        self.amountConsentToggleItem = itemsFactory.createAmountConsentToggle(amount: amount)
        self.legalConsentToggleItem = itemsFactory.createLegalConsentToggle()
    }

    // MARK: - Internal

    package func viewDidLoad() {
        tracker.sendInitialAnalytics()
        tracker.sendDidLoadEvent()
    }

    package func stopLoading() {
        guard state == .submitting else { return }
        state = .idle
    }

    package func performSubmit() {
        guard state != .submitting else { return }

        guard isValid else {
            state = .invalid
            return
        }

        state = .submitting
        onSubmit(makeDetails())
    }

    // MARK: - Private

    private var isValid: Bool {
        let areFieldsValid = items
            .lazy
            .compactMap { $0 as? ValidatableFormItem }
            .allSatisfy { $0.isValid() }
        return areFieldsValid && amountConsentToggleItem.value && legalConsentToggleItem.value
    }

    private func createItems() -> [any FormItem] {
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

    private func createSubmitButtonItem() -> FormButtonItem? {
        guard configuration.showsSubmitButton else { return nil }

        return itemsFactory.createPaymentButton { [weak self] in
            self?.performSubmit()
        }
    }

    private func makeDetails() -> BACSDirectDebitDetails {
        BACSDirectDebitDetails(
            paymentMethod: paymentMethod,
            holderName: holderNameItem.value,
            bankAccountNumber: bankAccountNumberItem.value,
            bankLocationId: sortCodeItem.value,
            shopperEmail: emailItem.value
        )
    }
}
