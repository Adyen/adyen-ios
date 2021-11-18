//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSDirectDebitPresenterProtocol: AnyObject {
    func viewDidLoad()
}

internal class BACSDirectDebitPresenter: BACSDirectDebitPresenterProtocol {

    // MARK: - Properties

    private let view: BACSDirectDebitInputFormViewProtocol
    private let router: BACSDirectDebitRouterProtocol
    private let itemsFactory: BACSDirectDebitItemsFactory

    // MARK: - Items

    private var holderNameItem: FormTextInputItem?
    private var numberItem: FormTextInputItem?
    private var sortCodeItem: FormTextInputItem?
    private var emailItem: FormTextInputItem?
    private var continueButton: FormButtonItem?

    // MARK: - Initializers

    internal init(view: BACSDirectDebitInputFormViewProtocol,
                  router: BACSDirectDebitRouterProtocol,
                  itemsFactory: BACSDirectDebitItemsFactory) {
        self.view = view
        self.router = router
        self.itemsFactory = itemsFactory
        setupItems()
        setupView()
    }

    // MARK: - BACSDirectDebitPresenterProtocol

    internal func viewDidLoad() {
        // TODO: - Complete logic
    }

    // MARK: - Private

    private func setupItems() {
        holderNameItem = itemsFactory.createHolderNameItem()
        numberItem = itemsFactory.createNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()

        continueButton = itemsFactory.createContinueButton()
        continueButton?.buttonSelectionHandler = continuePayment
    }

    private func setupView() {
        // TODO: - Remove force unwrapping
        view.add(item: holderNameItem!)
        view.add(item: numberItem!)
        view.add(item: sortCodeItem!)
        view.add(item: emailItem!)
        view.add(item: continueButton!)
    }

    private var isFormValid: Bool {
        [holderNameItem,
         numberItem,
         sortCodeItem,
         emailItem].compactMap { $0 }.allSatisfy { $0.isValid() }
    }

    private func continuePayment() {
        // TODO: - Continue logic

        view.displayValidation()
        // 1. Validate.

        guard isFormValid else { return }

        // 2. Build payment data.

        guard let holderName = holderNameItem?.value,
              let bankAccountNumber = numberItem?.value,
              let sortCode = sortCodeItem?.value,
              let shopperEmail = emailItem?.value else {
            return
        }

        let bacsDirectDebitData = BACSDirectDebitData(holderName: holderName,
                                                      bankAccountNumber: bankAccountNumber,
                                                      bacnkLocationId: sortCode,
                                                      shopperEmail: shopperEmail)
        // 3. Send payment details to router

        router.continuePayment(data: bacsDirectDebitData)
        print("BUTTON TAPPED")
    }
}
