//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif

/// A component that provides a form for SEPA Direct Debit payments.
@MainActor
package final class SEPADirectDebitComponent: PaymentComponent, PresentableComponent, LoadingComponent {

    /// Configuration for SEPA Direct Debit Component
    package typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// Component's configuration
    package var configuration: Configuration

    /// The SEPA Direct Debit payment method.
    package var paymentMethod: PaymentMethod {
        sepaDirectDebitPaymentMethod
    }
    
    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    /// Initializes the SEPA Direct Debit component.
    ///
    /// - Parameter paymentMethod: The SEPA Direct Debit payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: Configuration for the component.
    package init(
        paymentMethod: SEPADirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.sepaDirectDebitPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
    
    private let sepaDirectDebitPaymentMethod: SEPADirectDebitPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    package lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )
    
    package func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - View Controller
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showsSubmitButton,
            localizationParameters: configuration.localizationParameters,
            theme: configuration.theme
        )
        formViewController.delegate = self

        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(nameItem)
        formViewController.append(ibanItem)

        if configuration.showsSubmitButton {
            formViewController.append(button)
        }

        return formViewController
    }()
    
    // MARK: - Private
    
    private func didSelectSubmitButton() {
        guard validate() else {
            return
        }
        
        let details = SEPADirectDebitDetails(
            paymentMethod: sepaDirectDebitPaymentMethod,
            iban: ibanItem.value,
            ownerName: nameItem.value
        )
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: context.amount, order: order))
    }
    
    // MARK: - Form Items
    
    internal lazy var nameItem: FormTextInputItem = {
        let nameItem = FormTextInputItem(style: configuration.style.textField)
        nameItem.title = localizedString(.sepaNameItemTitle, configuration.localizationParameters)
        nameItem.placeholder = localizedString(.sepaNameItemPlaceholder, configuration.localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 2)
        nameItem.validationFailureMessage = localizedString(.sepaNameItemInvalid, configuration.localizationParameters)
        nameItem.autocapitalizationType = .words
        nameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "nameItem")
        return nameItem
    }()
    
    internal lazy var ibanItem: FormTextInputItem = {
        func localizedPlaceholder() -> String {
            let countryCode = Locale.current.regionCode
            let specification = countryCode.flatMap(IBANSpecification.init(forCountryCode:))
            let example = specification?.example ?? "NL26INGB0336169116"
            
            return IBANFormatter().formattedValue(for: example)
        }
        
        let ibanItem = FormTextInputItem(style: configuration.style.textField)
        ibanItem.title = localizedString(.sepaIbanItemTitle, configuration.localizationParameters)
        ibanItem.placeholder = localizedPlaceholder()
        ibanItem.formatter = IBANFormatter()
        ibanItem.validator = IBANValidator()
        ibanItem.validationFailureMessage = localizedString(.sepaIbanItemInvalid, configuration.localizationParameters)
        ibanItem.autocapitalizationType = .allCharacters
        ibanItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "ibanItem")
        return ibanItem
    }()

    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(
            with: context.amount,
            style: .immediate,
            configuration.localizationParameters
        )
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

}

@_spi(AdyenInternal)
extension SEPADirectDebitComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension SEPADirectDebitComponent: ViewControllerDelegate {}

// MARK: - SubmitCustomizable

extension SEPADirectDebitComponent: SubmittableComponent {

    package func submit() {
        didSelectSubmitButton()
    }

    package func validate() -> Bool {
        formViewController.validate()
    }
}
