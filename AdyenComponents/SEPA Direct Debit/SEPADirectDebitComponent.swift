//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for SEPA Direct Debit payments.
public final class SEPADirectDebitComponent: PaymentComponent, PresentableComponent, Localizable, LoadingComponent {
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// Describes the component's UI style.
    public let style: FormComponentStyle
    
    /// The SEPA Direct Debit payment method.
    public var paymentMethod: PaymentMethod {
        sepaDirectDebitPaymentMethod
    }
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the SEPA Direct Debit component.
    ///
    /// - Parameter paymentMethod: The SEPA Direct Debit payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: SEPADirectDebitPaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = FormComponentStyle()) {
        self.style = style
        self.apiContext = apiContext
        self.sepaDirectDebitPaymentMethod = paymentMethod
    }
    
    private let sepaDirectDebitPaymentMethod: SEPADirectDebitPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController, style: style)
    
    /// :nodoc:
    public var requiresModalPresentation: Bool = true
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
    
    // MARK: - View Controller
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.name
        formViewController.append(nameItem)
        formViewController.append(ibanItem)
        formViewController.append(button)

        return formViewController
    }()
    
    // MARK: - Private
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else {
            return
        }
        
        let details = SEPADirectDebitDetails(paymentMethod: sepaDirectDebitPaymentMethod,
                                             iban: ibanItem.value,
                                             ownerName: nameItem.value)
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
    }
    
    // MARK: - Form Items
    
    internal lazy var nameItem: FormTextInputItem = {
        let nameItem = FormTextInputItem(style: style.textField)
        nameItem.title = localizedString(.sepaNameItemTitle, localizationParameters)
        nameItem.placeholder = localizedString(.sepaNameItemPlaceholder, localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 2)
        nameItem.validationFailureMessage = localizedString(.sepaNameItemInvalid, localizationParameters)
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
        
        let ibanItem = FormTextInputItem(style: style.textField)
        ibanItem.title = localizedString(.sepaIbanItemTitle, localizationParameters)
        ibanItem.placeholder = localizedPlaceholder()
        ibanItem.formatter = IBANFormatter()
        ibanItem.validator = IBANValidator()
        ibanItem.validationFailureMessage = localizedString(.sepaIbanItemInvalid, localizationParameters)
        ibanItem.autocapitalizationType = .allCharacters
        ibanItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "ibanItem")
        return ibanItem
    }()

    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(with: payment?.amount,
                                                style: .immediate,
                                                localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

}

extension SEPADirectDebitComponent: TrackableComponent {}
