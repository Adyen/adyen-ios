//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for SEPA Direct Debit payments.
public final class SEPADirectDebitComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// Describes the component's UI style.
    public let style: AnyFormComponentStyle
    
    /// Indicates the navigation level style.
    public let navigationStyle: NavigationStyle
    
    /// The SEPA Direct Debit payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter paymentMethod: The SEPA Direct Debit payment method.
    /// - Parameter style: The Component's UI style.
    /// - Parameter navigationStyle: The navigation level style.
    public init(paymentMethod: SEPADirectDebitPaymentMethod,
                style: AnyFormComponentStyle = FormComponentStyle(),
                navigationStyle: NavigationStyle = NavigationStyle()) {
        self.paymentMethod = paymentMethod
        self.style = style
        self.sepaDirectDebitPaymentMethod = paymentMethod
        self.navigationStyle = navigationStyle
    }
    
    private let sepaDirectDebitPaymentMethod: SEPADirectDebitPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        return ComponentViewController(rootViewController: formViewController,
                                       style: navigationStyle,
                                       cancelButtonHandler: didSelectCancelButton)
    }()
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator.value = false
        
        completion?()
    }
    
    // MARK: - View Controller
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        
        let headerItem = FormHeaderItem(style: style.header)
        headerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: paymentMethod.name)
        headerItem.title = paymentMethod.name
        formViewController.append(headerItem)
        
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
        
        delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
    }
    
    private lazy var didSelectCancelButton: (() -> Void) = { [weak self] in
        guard let self = self else { return }
        
        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
    
    // MARK: - Form Items
    
    internal lazy var nameItem: FormTextItem = {
        let nameItem = FormTextItem(style: style.textField)
        nameItem.title = ADYLocalizedString("adyen.sepa.nameItem.title", localizationParameters)
        nameItem.placeholder = ADYLocalizedString("adyen.sepa.nameItem.placeholder", localizationParameters)
        nameItem.validator = LengthValidator(minimumLength: 2)
        nameItem.validationFailureMessage = ADYLocalizedString("adyen.sepa.nameItem.invalid", localizationParameters)
        nameItem.autocapitalizationType = .words
        nameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "nameItem")
        
        return nameItem
    }()
    
    internal lazy var ibanItem: FormTextItem = {
        func localizedPlaceholder() -> String {
            let countryCode = Locale.current.regionCode
            let specification = countryCode.flatMap(IBANSpecification.init(forCountryCode:))
            let example = specification?.example ?? "NL26INGB0336169116"
            
            return IBANFormatter().formattedValue(for: example)
        }
        
        let ibanItem = FormTextItem(style: style.textField)
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
