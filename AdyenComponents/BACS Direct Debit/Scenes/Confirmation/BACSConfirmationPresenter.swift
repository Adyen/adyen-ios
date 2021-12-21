//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSConfirmationPresenterProtocol: AnyObject {
    func viewDidLoad()
    func startLoading()
    func stopLoading()
}

internal class BACSConfirmationPresenter: BACSConfirmationPresenterProtocol {

    // MARK: - Properties

    private let data: BACSDirectDebitData
    private let view: BACSConfirmationViewProtocol
    private weak var router: BACSDirectDebitRouterProtocol?
    private let itemsFactory: BACSItemsFactoryProtocol

    // MARK: - Items

    internal var holderNameItem: FormTextInputItem?
    internal var bankAccountNumberItem: FormTextInputItem?
    internal var sortCodeItem: FormTextInputItem?
    internal var emailItem: FormTextInputItem?
    internal var paymentButtonItem: FormButtonItem?

    // MARK: - Initializers

    internal init(data: BACSDirectDebitData,
                  view: BACSConfirmationViewProtocol,
                  router: BACSDirectDebitRouterProtocol,
                  itemsFactory: BACSItemsFactoryProtocol) {
        self.data = data
        self.router = router
        self.view = view
        self.itemsFactory = itemsFactory
    }

    // MARK: - BACSDirectDebitConfirmationPresenterProtocol

    internal func viewDidLoad() {
        createItems()
        setupView()
    }

    internal func startLoading() {
        paymentButtonItem?.showsActivityIndicator = true
        view.setUserInteraction(enabled: false)
    }

    internal func stopLoading() {
        paymentButtonItem?.showsActivityIndicator = false
        view.setUserInteraction(enabled: true)
    }

    // MARK: - Private

    private func createItems() {
        holderNameItem = itemsFactory.createHolderNameItem()
        bankAccountNumberItem = itemsFactory.createBankAccountNumberItem()
        sortCodeItem = itemsFactory.createSortCodeItem()
        emailItem = itemsFactory.createEmailItem()
        paymentButtonItem = itemsFactory.createPaymentButton()
        paymentButtonItem?.buttonSelectionHandler = handlePayment

        fillItems()
    }

    private func setupView() {
        view.add(item: holderNameItem)
        view.add(item: bankAccountNumberItem)
        view.add(item: sortCodeItem)
        view.add(item: emailItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 2))
        view.add(item: paymentButtonItem)
        view.add(item: FormSpacerItem(numberOfSpaces: 1))

        setupItems()
    }

    private func setupItems() {
        holderNameItem?.isEnabled = false
        bankAccountNumberItem?.isEnabled = false
        sortCodeItem?.isEnabled = false
        emailItem?.isEnabled = false
    }

    private func fillItems() {
        holderNameItem?.value = data.holderName
        bankAccountNumberItem?.value = data.bankAccountNumber
        sortCodeItem?.value = data.bankLocationId
        emailItem?.value = data.shopperEmail
    }

    private func handlePayment() {
        router?.confirmPayment(with: data)
    }
}
