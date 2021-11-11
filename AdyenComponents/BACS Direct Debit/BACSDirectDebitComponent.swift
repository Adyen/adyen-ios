//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

public final class BACSDirectDebitComponent {

    public let paymentMethod: PaymentMethod
    public let apiContext: APIContext
    public let style: FormComponentStyle
    public var localizationParameters: LocalizationParameters?

    // MARK: - Initializers

    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = .init()) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.style = style
    }

    // MARK: - View Controller

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.name

        // TODO: - Items logic


        return formViewController
    }()

    // MARK: - Form Items

    internal lazy var holderNameItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        // TODO: - Replace with localized version
        textItem.title = "Bank account holder name"
        textItem.placeholder = "Bank account placeholder"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .words

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "holderNameItem")
        textItem.identifier = identifier
        return textItem
    }()

    internal lazy var accountNumberItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        // TODO: - Replace with localized version
        textItem.title = "Bank account number"
        textItem.placeholder = "Bank account number"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "accountNumberItem")
        textItem.identifier = identifier
        return textItem
    }()

    internal lazy var sortCodeItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        // TODO: - Replace with localized version
        textItem.title = "Sort code"
        textItem.placeholder = "Sort code"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "sortCodeItem")
        textItem.identifier = identifier
        return textItem
    }()

    internal lazy var emailItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        // TODO: - Replace with localized version
        textItem.title = "Email"
        textItem.placeholder = "Email"

        // TODO: - Set up validator
        // textItem.validator = ...
        // textItem.validationFailureMessage = ...

        textItem.autocapitalizationType = .none

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "emailItem")
        textItem.identifier = identifier
        return textItem
    }()

    internal lazy var continueButton: FormButtonItem = {
        let buttonItem = FormButtonItem(style: style.mainButtonItem)

        // TODO: - Replace with localized version
        buttonItem.title = "Continue"

        // TODO: - Handle button action
        buttonItem.buttonSelectionHandler = {

        }

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "continueButtonItem")
        buttonItem.identifier = identifier
        return buttonItem
    }()
}
