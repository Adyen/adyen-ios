//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for SEPA Direct Debit payments.
public final class SEPADirectDebitComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// Describes the component's UI style.
    public let style: FormComponentStyle
    
    /// The SEPA Direct Debit payment method.
    public var paymentMethod: PaymentMethod {
        sepaDirectDebitPaymentMethod
    }
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controller's title.
    /// Defaults to true.
    public var showsLargeTitle = true
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the SEPA Direct Debit component.
    ///
    /// - Parameter paymentMethod: The SEPA Direct Debit payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: SEPADirectDebitPaymentMethod,
                style: FormComponentStyle = FormComponentStyle()) {
        self.style = style
        self.sepaDirectDebitPaymentMethod = paymentMethod
    }
    
    private let sepaDirectDebitPaymentMethod: SEPADirectDebitPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        return formViewController
    }
    
    /// :nodoc:
    public var requiresModalPresentation: Bool = true
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator.value = false
        formViewController.view.isUserInteractionEnabled = true
        
        completion?()
    }
    
    // MARK: - View Controller
    
    private lazy var formViewController: FormViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        
        if showsLargeTitle {
            let headerItem = FormHeaderItem(style: style.header)
            headerItem.title = paymentMethod.name
            headerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: paymentMethod.name)
            formViewController.append(headerItem)
        } else {
            formViewController.title = paymentMethod.name
        }
        
        formViewController.append(nameItem)
        formViewController.append(ibanItem)
        formViewController.append(footerItem)
        
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
        footerItem.showsActivityIndicator.value = true
        formViewController.view.isUserInteractionEnabled = false
        
        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
    
    // MARK: - Form Items
    
    internal lazy var nameItem: FormTextInputItem = {
        let nameItem = FormTextInputItem(style: style.textField)
        nameItem.title = ADYLocalizedString("adyen.sepa.nameItem.title", localizationParameters)
        nameItem.placeholder = ADYLocalizedString("adyen.sepa.nameItem.placeholder", localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 2)
        nameItem.validationFailureMessage = ADYLocalizedString("adyen.sepa.nameItem.invalid", localizationParameters)
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
        ibanItem.title = ADYLocalizedString("adyen.sepa.ibanItem.title", localizationParameters)
        ibanItem.placeholder = localizedPlaceholder()
        ibanItem.formatter = IBANFormatter()
        ibanItem.validator = IBANValidator()
        ibanItem.validationFailureMessage = ADYLocalizedString("adyen.sepa.ibanItem.invalid", localizationParameters)
        ibanItem.autocapitalizationType = .allCharacters
        ibanItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "ibanItem")
        return ibanItem
    }()
    
    internal lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem(style: style.footer)
        footerItem.title = ADYLocalizedString("adyen.sepa.consentLabel", localizationParameters)
        footerItem.submitButtonTitle = ADYLocalizedSubmitButtonTitle(with: payment?.amount, localizationParameters)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        footerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footerItem")
        return footerItem
    }()
    
}
