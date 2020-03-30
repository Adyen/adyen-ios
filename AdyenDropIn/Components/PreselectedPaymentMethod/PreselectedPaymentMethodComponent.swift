//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Defines the methods a delegate of the preselected payment method component should implement.
internal protocol PreselectedPaymentMethodComponentDelegate: AnyObject {
    
    /// Invoked when user decided to change payment method.
    func didRequestAllPaymentMethods()
    
    /// Invoked when user decided to proceed with stored payment method.
    func didProceed(with component: PaymentComponent)
}

/// A component that presents a list of items for each payment method with a component.
internal final class PreselectedPaymentMethodComponent: PresentableComponent, Localizable {
    
    private let title: String
    private let defaultComponent: PaymentComponent
    
    /// Delegate actions.
    internal weak var delegate: PreselectedPaymentMethodComponentDelegate?
    
    /// Describes the component's UI style.
    internal let style: PreselectedPaymentMethodStyle
    
    /// Initializes the list component.
    ///
    /// - Parameter components: The components to display in the list.
    /// - Parameter style: The component's UI style.
    internal init(component: PaymentComponent, title: String, style: PreselectedPaymentMethodStyle) {
        self.title = title
        self.style = style
        self.defaultComponent = component
    }
    
    // MARK: - View Controller
    
    public var viewController: UIViewController {
        preselectedPaymentMethodViewController
    }
    
    /// :nodoc:
    private lazy var preselectedPaymentMethodViewController: PreselectedPaymentMethodViewController = {
        let paymentMethod = self.defaultComponent.paymentMethod
        let displayInformation = paymentMethod.localizedDisplayInformation(using: localizationParameters)
        var listItem = ListItem(title: displayInformation.title, style: self.style.item)
        listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
        listItem.imageURL = LogoURLProvider.logoURL(for: paymentMethod, environment: environment)
        listItem.subtitle = displayInformation.subtitle
        
        let controller = PreselectedPaymentMethodViewController(listItem: listItem,
                                                                style: style,
                                                                payment: self.payment,
                                                                didSelectSubmit: { [unowned self] in
                                                                    self.preselectedPaymentMethodViewController.isBusy = true
                                                                    self.delegate?.didProceed(with: self.defaultComponent)
                                                                },
                                                                didSelectOpenAll: { [unowned self] in
                                                                    self.delegate?.didRequestAllPaymentMethods()
        })
        controller.title = self.title
        return controller
    }()
    
    internal func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        preselectedPaymentMethodViewController.isBusy = false
        completion?()
    }
    
    // MARK: - Localization
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
}
