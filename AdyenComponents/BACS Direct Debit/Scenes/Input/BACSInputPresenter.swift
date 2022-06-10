//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal protocol BACSInputPresenterProtocol: AnyObject {
    var amount: Amount? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func resetForm()
}

internal class BACSInputPresenter: BACSInputPresenterProtocol {

    // MARK: - Properties

    private let view: BACSInputFormViewProtocol
    private let tracker: BACSDirectDebitComponentTrackerProtocol
    private weak var router: BACSDirectDebitRouterProtocol?
    private var data: BACSDirectDebitData?

    // MARK: - Items

    internal var holderNameItem: FormTextInputItem?
    internal var bankAccountNumberItem: FormTextInputItem?
    internal var sortCodeItem: FormTextInputItem?
    internal var emailItem: FormTextInputItem?
    internal var amountConsentToggleItem: FormToggleItem?
    internal var legalConsentToggleItem: FormToggleItem?
    internal var continueButtonItem: FormButtonItem?
    
    internal let itemsFactory: BACSItemsFactoryProtocol
    
    internal var amount: Amount? {
        didSet {
            amountConsentToggleItem?.title = itemsFactory.createConsentText(with: amount)
        }
    }

    // MARK: - Initializers

    internal init(view: BACSInputFormViewProtocol,
                  router: BACSDirectDebitRouterProtocol,
                  tracker: BACSDirectDebitComponentTrackerProtocol,
                  itemsFactory: BACSItemsFactoryProtocol) {
        self.view = view
        self.router = router
        self.tracker = tracker
        self.itemsFactory = itemsFactory
    }

    // MARK: - BACSInputPresenterProtocol

    internal func viewDidLoad() {
        tracker.sendTelemetryEvent()
        createItems()
        setupView()
    }

    internal func viewWillAppear() {
        restoreFields()
    }

    internal func resetForm() {
        holderNameItem?.value = ""
        bankAccountNumberItem?.value = ""
        sortCodeItem?.value = ""
        emailItem?.value = ""

        amountConsentToggleItem?.value = false
        legalConsentToggleItem?.value = false
        data = nil
    }

    // MARK: - Private

    private func createItems() {
        holderNameItem = itemsFactory.createHolderNameItem()
        bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()
        amountConsentToggleItem = itemsFactory.createAmountConsentToggle(amount: amount)
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

    private func restoreFields() {
        guard let data = data else { return }
        holderNameItem?.value = data.holderName
        bankAccountNumberItem?.value = data.bankAccountNumber
        sortCodeItem?.value = data.bankLocationId
        emailItem?.value = data.shopperEmail

        amountConsentToggleItem?.value = true
        legalConsentToggleItem?.value = true
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
        router?.presentConfirmation(with: bacsDirectDebitData)
    }
}
