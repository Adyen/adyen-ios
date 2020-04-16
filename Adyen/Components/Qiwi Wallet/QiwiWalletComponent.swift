//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// :nodoc:
    public var paymentMethod: PaymentMethod { qiwiWalletPaymentMethod }
    
    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?
    
    /// :nodoc:
    public var viewController: UIViewController { formViewController }
    
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
    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameter paymentMethod: The Qiwi Wallet payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: QiwiWalletPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.qiwiWalletPaymentMethod = paymentMethod
        self.style = style
    }
    
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
        
        formViewController.append(phoneNumberItem)
        formViewController.append(footerItem)
        
        return formViewController
    }()
    
    /// The full phone number item
    internal lazy var phoneNumberItem: FormPhoneNumberItem = {
        let item = FormPhoneNumberItem(selectableValues: selectableValues,
                                       style: style.textField,
                                       localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")
        return item
    }()
    
    /// The footer item.
    internal lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem(style: style.footer)
        footerItem.submitButtonTitle = ADYLocalizedString("adyen.continueTo", localizationParameters, qiwiWalletPaymentMethod.name)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        footerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footerItem")
        return footerItem
    }()
    
    internal var selectableValues: [PhoneExtensionPickerItem] {
        qiwiWalletPaymentMethod.phoneExtensions.map {
            let title = "\($0.countryDisplayName) (\($0.value))"
            return PhoneExtensionPickerItem(identifier: $0.countryCode,
                                            title: title,
                                            phoneExtension: $0.value)
        }
    }
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }
        
        let details = QiwiWalletDetails(paymentMethod: paymentMethod,
                                        phonePrefix: phoneNumberItem.prefix,
                                        phoneNumber: phoneNumberItem.value)
        footerItem.showsActivityIndicator.value = true
        formViewController.view.isUserInteractionEnabled = false
        
        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
    
}
