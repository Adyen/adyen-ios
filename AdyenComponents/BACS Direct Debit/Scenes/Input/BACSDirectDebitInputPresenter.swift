//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSDirectDebitInputPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didCancel()
}

internal class BACSDirectDebitPresenter: BACSDirectDebitInputPresenterProtocol {

    // MARK: - Properties

    private let view: BACSDirectDebitInputFormViewProtocol
    private let router: BACSDirectDebitRouterProtocol
    private let itemsFactory: BACSDirectDebitItemsFactoryProtocol
    private var data: BACSDirectDebitData?

    // MARK: - Items

    internal var holderNameItem: FormTextInputItem?
    internal var bankAccountNumberItem: FormTextInputItem?
    internal var sortCodeItem: FormTextInputItem?
    internal var emailItem: FormTextInputItem?
    internal var amountConsentToggleItem: FormToggleItem?
    internal var legalConsentToggleItem: FormToggleItem?
    internal var continueButtonItem: FormButtonItem?

    // MARK: - Initializers

    internal init(view: BACSDirectDebitInputFormViewProtocol,
                  router: BACSDirectDebitRouterProtocol,
                  itemsFactory: BACSDirectDebitItemsFactoryProtocol) {
        self.view = view
        self.router = router
        self.itemsFactory = itemsFactory
        setupItems()
        setupView()
    }

    // MARK: - BACSDirectDebitPresenterProtocol

    internal func viewDidLoad() {
        view.setupNavigationBar()
    }

    @objc
    internal func didCancel() {
        router.cancelPayment()
    }

    // MARK: - Private

    private func setupItems() {
        holderNameItem = itemsFactory.createHolderNameItem()
        bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()
        amountConsentToggleItem = itemsFactory.createAmountConsentToggle()
        legalConsentToggleItem = itemsFactory.createLegalConsentToggle()

        continueButtonItem = itemsFactory.createContinueButton()
        continueButtonItem?.buttonSelectionHandler = continuePayment
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
        view.add(item: continueButtonItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 1))
    }

    private func validateForm() -> Bool {
        view.displayValidation()

        guard let amountTermsAccepted = amountConsentToggleItem?.value,
              let legalTermsAccepted = legalConsentToggleItem?.value,
              amountTermsAccepted, legalTermsAccepted else {
            return false
        }

        return [holderNameItem,
                bankAccountNumberItem,
                sortCodeItem,
                emailItem].compactMap { $0 }
            .allSatisfy { $0.isValid() }
    }

    private func continuePayment() {
        guard validateForm() else { return }

        guard let holderName = holderNameItem?.value,
              let bankAccountNumber = bankAccountNumberItem?.value,
              let sortCode = sortCodeItem?.value,
              let shopperEmail = emailItem?.value else {
            return
        }

        let bacsDirectDebitData = BACSDirectDebitData(holderName: holderName,
                                                      bankAccountNumber: bankAccountNumber,
                                                      bankLocationId: sortCode,
                                                      shopperEmail: shopperEmail)
        self.data = bacsDirectDebitData
        router.presentConfirmation(with: bacsDirectDebitData)
    }
}
