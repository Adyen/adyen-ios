//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for SEPA Direct Debit payments.
public final class SEPADirectDebitComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// The SEPA Direct Debit payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter paymentMethod: The SEPA Direct Debit payment method.
    public init(paymentMethod: SEPADirectDebitPaymentMethod) {
        self.paymentMethod = paymentMethod
        self.sepaDirectDebitPaymentMethod = paymentMethod
    }
    
    private let sepaDirectDebitPaymentMethod: SEPADirectDebitPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        return ComponentViewController(rootViewController: formViewController, cancelButtonHandler: didSelectCancelButton)
    }()
    
    /// :nodoc:
    public var localizationTable: String?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator.value = false
        
        completion?()
    }
    
    // MARK: - View Controller
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController()
        formViewController.localizationTable = localizationTable
        
        let headerItem = FormHeaderItem()
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
        let nameItem = FormTextItem()
        nameItem.title = ADYLocalizedString("adyen.sepa.nameItem.title", localizationTable)
        nameItem.placeholder = ADYLocalizedString("adyen.sepa.nameItem.placeholder", localizationTable)
        nameItem.validator = LengthValidator(minimumLength: 2)
        nameItem.validationFailureMessage = ADYLocalizedString("adyen.sepa.nameItem.invalid", localizationTable)
        nameItem.autocapitalizationType = .words
        
        return nameItem
    }()
    
    internal lazy var ibanItem: FormTextItem = {
        func localizedPlaceholder() -> String {
            let countryCode = Locale.current.regionCode
            let specification = countryCode.flatMap(IBANSpecification.init(forCountryCode:))
            let example = specification?.example ?? "NL26INGB0336169116"
            
            return IBANFormatter().formattedValue(for: example)
        }
        
        let ibanItem = FormTextItem()
        ibanItem.title = ADYLocalizedString("adyen.sepa.ibanItem.title", localizationTable)
        ibanItem.placeholder = localizedPlaceholder()
        ibanItem.formatter = IBANFormatter()
        ibanItem.validator = IBANValidator()
        ibanItem.validationFailureMessage = ADYLocalizedString("adyen.sepa.ibanItem.invalid", localizationTable)
        ibanItem.autocapitalizationType = .allCharacters
        
        return ibanItem
    }()
    
    internal lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem()
        footerItem.title = ADYLocalizedString("adyen.sepa.consentLabel", localizationTable)
        footerItem.submitButtonTitle = ADYLocalizedSubmitButtonTitle(with: payment?.amount, localizationTable)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return footerItem
    }()
}
