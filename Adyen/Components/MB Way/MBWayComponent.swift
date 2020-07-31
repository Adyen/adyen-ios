//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for MB Way payments.
public final class MBWayComponent: PaymentComponent, PresentableComponent, Localizable {
    /// :nodoc:
    public var paymentMethod: PaymentMethod { mbWayPaymentMethod }
    
    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController, style: style)
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// Describes the component's UI style.
    public let style: FormComponentStyle
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controller's title.
    /// Defaults to true.
    public var showsLargeTitle = true
    
    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
    /// :nodoc:
    private let mbWayPaymentMethod: MBWayPaymentMethod
    
    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The MB Way payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: MBWayPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.mbWayPaymentMethod = paymentMethod
        self.style = style
    }
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }
    
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
        
        formViewController.append(emailItem)
        formViewController.append(phoneNumberItem)
        formViewController.append(footerItem)
        
        return formViewController
    }()
    
    /// The email item.
    internal lazy var emailItem: FormTextInputItem = {
        let emailItem = FormTextInputItem(style: style.textField)
        emailItem.title = ADYLocalizedString("adyen.emailItem.title", localizationParameters)
        emailItem.placeholder = ADYLocalizedString("adyen.emailItem.placeholder", localizationParameters)
        emailItem.validator = EmailValidator()
        emailItem.validationFailureMessage = ADYLocalizedString("adyen.emailItem.invalid", localizationParameters)
        emailItem.autocapitalizationType = .none
        emailItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "emailItem")
        return emailItem
    }()
    
    /// The full phone number item.
    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(selectableValues: [PhoneExtensionPickerItem(identifier: "PT",
                                                                                   title: "+351",
                                                                                   phoneExtension: "+351")],
                                       style: style.textField,
                                       localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
        return item
    }()
    
    /// The footer item.
    internal lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem(style: style.footer)
        footerItem.submitButtonTitle = ADYLocalizedString("adyen.continueTo", localizationParameters, mbWayPaymentMethod.name)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        footerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footerItem")
        return footerItem
    }()
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }
        
        let details = MBWayDetails(paymentMethod: paymentMethod,
                                   telephoneNumber: phoneNumberItem.phoneNumber,
                                   shopperEmail: emailItem.value)
        footerItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        
        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
