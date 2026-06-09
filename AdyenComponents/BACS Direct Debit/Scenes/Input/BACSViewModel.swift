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

internal protocol BACSViewModelProtocol: AnyObject {
    func viewDidLoad()
    func stopLoading()
    func onSubmitButtonTap()
}

internal class BACSViewModel: BACSViewModelProtocol {

    // MARK: - Properties

    private let view: BACSView
    private let tracker: BACSDirectDebitComponentTrackerProtocol
    internal let itemsFactory: BACSItemsFactoryProtocol
    private let amount: Amount?
    private let onSubmitTap: (_ data: BACSDirectDebitData) -> Void

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
        view: BACSView,
        tracker: BACSDirectDebitComponentTrackerProtocol,
        itemsFactory: BACSItemsFactoryProtocol,
        amount: Amount?,
        onSubmitTap: @escaping (_ data: BACSDirectDebitData) -> Void
    ) {
        self.view = view
        self.tracker = tracker
        self.itemsFactory = itemsFactory
        self.amount = amount
        self.onSubmitTap = onSubmitTap
    }

    // MARK: - BACSInputPresenterProtocol

    internal func viewDidLoad() {
        tracker.sendInitialAnalytics()
        tracker.sendDidLoadEvent()
        createItems()
        setupView()
    }

    internal func stopLoading() {
        submitButtonItem?.showsActivityIndicator = false
    }

    internal func onSubmitButtonTap() {
        startLoading()

        guard validateForm() else {
            stopLoading()
            return
        }

        guard let holderName = holderNameItem?.value,
              let bankAccountNumber = bankAccountNumberItem?.value,
              let sortCode = sortCodeItem?.value,
              let shopperEmail = emailItem?.value else {
            return
        }

        let bacsDirectDebitData = BACSDirectDebitData(
            holderName: holderName,
            bankAccountNumber: bankAccountNumber,
            bankLocationId: sortCode,
            shopperEmail: shopperEmail
        )
        onSubmitTap(bacsDirectDebitData)
    }

    // MARK: - Private

    private func startLoading() {
        submitButtonItem?.showsActivityIndicator = true
    }

    private func createItems() {
        holderNameItem = itemsFactory.createHolderNameItem()
        bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()
        amountConsentToggleItem = itemsFactory.createAmountConsentToggle(amount: amount)
        legalConsentToggleItem = itemsFactory.createLegalConsentToggle()

        submitButtonItem = itemsFactory.createPaymentButton()
        submitButtonItem?.buttonSelectionHandler = onSubmitButtonTap
    }

    private func setupView() {
        view.add(item: holderNameItem)
        view.add(item: bankAccountNumberItem)
        view.add(item: sortCodeItem)
        view.add(item: emailItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 2))
        view.add(item: amountConsentToggleItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 1))
        view.add(item: legalConsentToggleItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 2))
        view.add(item: submitButtonItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 1))
    }

    private func validateForm() -> Bool {
        view.displayValidation()

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
