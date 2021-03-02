//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Defines the methods a delegate of the preselected payment method component should implement.
internal protocol PreselectedPaymentMethodComponentDelegate: AnyObject {
    
    /// Invoked when user decided to change payment method.
    func didRequestAllPaymentMethods()
    
    /// Invoked when user decided to proceed with stored payment method.
    func didProceed(with component: PaymentComponent)
}

/// A component that presents a single preselected payment method and option to open more payment methods.
internal final class PreselectedPaymentMethodComponent: ComponentLoader,
    PresentableComponent,
    PaymentAwareComponent,
    Localizable {
    
    private let title: String
    private let defaultComponent: PaymentComponent
    
    /// Delegate actions.
    internal weak var delegate: PreselectedPaymentMethodComponentDelegate?
    
    /// Describes the component's UI style.
    internal var style: FormComponentStyle
    
    /// Describes the list item's UI style.
    internal let listItemStyle: ListItemStyle
    
    /// Initializes the list component.
    ///
    /// - Parameter components: The components to display in the list.
    /// - Parameter style: The component's UI style.
    internal init(component: PaymentComponent, title: String, style: FormComponentStyle, listItemStyle: ListItemStyle) {
        self.title = title
        self.style = style
        self.listItemStyle = listItemStyle
        self.defaultComponent = component
    }
    
    // MARK: - View Controller
    
    public lazy var viewController: UIViewController = {
        let paymentMethod = defaultComponent.paymentMethod
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        
        formViewController.append(listItem)
        formViewController.append(submitButtonItem.withPadding(padding: .init(top: 0, left: 0, bottom: -8, right: 0)))
        formViewController.append(separator)
        formViewController.append(openAllButtonItem.withPadding(padding: .init(top: 0, left: 0, bottom: -14, right: 0)))
        
        formViewController.title = title
        return formViewController
    }()
    
    private lazy var separator: FormSeparatorItem = {
        let separator = FormSeparatorItem(color: style.separatorColor ?? UIColor.Adyen.componentSeparator)
        separator.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "separator")
        return separator
    }()
    
    private lazy var listItem: ListItem = {
        let paymentMethod = defaultComponent.paymentMethod
        let displayInformation = paymentMethod.localizedDisplayInformation(using: localizationParameters)
        var listItem = ListItem(title: displayInformation.title, style: self.listItemStyle)
        listItem.imageURL = LogoURLProvider.logoURL(for: paymentMethod, environment: environment)
        listItem.subtitle = displayInformation.subtitle
        listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "defaultComponent")
        return listItem
    }()
    
    private lazy var submitButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.title = ADYLocalizedSubmitButtonTitle(with: payment?.amount,
                                                   style: .immediate,
                                                   localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "submitButton")
        let component = self.defaultComponent
        item.buttonSelectionHandler = { [weak self] in
            self?.delegate?.didProceed(with: component)
        }
        return item
    }()
    
    private lazy var openAllButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: style.secondaryButtonItem)
        item.title = ADYLocalizedString("adyen.dropIn.preselected.openAll.title", localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "openAllButton")
        item.buttonSelectionHandler = { [weak self] in
            self?.delegate?.didRequestAllPaymentMethods()
        }
        return item
    }()
    
    public func startLoading(for component: PaymentComponent) {
        guard component === defaultComponent else { return }
        submitButtonItem.showsActivityIndicator = true
        openAllButtonItem.enabled = false
    }
    
    internal func stopLoading(completion: (() -> Void)?) {
        submitButtonItem.showsActivityIndicator = false
        openAllButtonItem.enabled = true
        completion?()
    }
    
    // MARK: - Localization
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
}
