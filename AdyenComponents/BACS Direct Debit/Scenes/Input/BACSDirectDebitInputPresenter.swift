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
    private let itemsFactory: BACSDirectDebitItemsFactory
    private let localizationParameters: LocalizationParameters

    // MARK: - Items

    private var holderNameItem: FormTextInputItem?
    private var numberItem: FormTextInputItem?
    private var sortCodeItem: FormTextInputItem?
    private var emailItem: FormTextInputItem?
    private var continueButton: FormButtonItem?

    // MARK: - Initializers

    internal init(view: BACSDirectDebitInputFormViewProtocol,
                  itemsFactory: BACSDirectDebitItemsFactory,
                  localizationParameters: LocalizationParameters) {
        self.view = view
        self.itemsFactory = itemsFactory
        self.localizationParameters = localizationParameters
        setupItems()
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
    }

    private func setupView() {
        // TODO: - Remove force unwrapping
        view.append(item: holderNameItem!)
        view.append(item: numberItem!)
        view.append(item: sortCodeItem!)
        view.append(item: emailItem!)
        view.append(item: continueButton!)
    }
}
