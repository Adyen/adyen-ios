//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that presents a list of items for each payment method with a component.
internal final class PaymentMethodListComponent: ComponentLoader, PresentableComponent, Localizable, Cancellable {
    
    /// :nodoc:
    internal let apiContext: APIContext
    
    /// The components that are displayed in the list.
    internal let paymentMethodSections: [PaymentMethodsSection]
    
    /// The delegate of the payment method list component.
    internal weak var delegate: PaymentMethodListComponentDelegate?

    /// Call back when the list is dismissed.
    internal var onCancel: (() -> Void)?
    
    /// Describes the component's UI style.
    internal let style: ListComponentStyle
    
    /// Initializes the list component.
    ///
    /// - Parameter paymentMethods: The payment methods to display in the list.
    /// - Parameter style: The component's UI style.
    internal init(apiContext: APIContext,
                  paymentMethods: [PaymentMethodsSection],
                  style: ListComponentStyle = ListComponentStyle()) {
        self.apiContext = apiContext
        self.paymentMethodSections = paymentMethods
        self.style = style
    }
    
    // MARK: - View Controller
    
    /// :nodoc:
    internal var viewController: UIViewController { listViewController }

    private let brandProtectedComponents: Set = ["applepay"]
    
    internal lazy var listViewController: ListViewController = {
        func item(for paymentMethod: PaymentMethod) -> ListItem {
            let displayInformation = paymentMethod.localizedDisplayInformation(using: localizationParameters)
            let isProtected = brandProtectedComponents.contains(paymentMethod.type)
            let listItem = ListItem(title: displayInformation.title,
                                    style: style.listItem,
                                    canModifyIcon: !isProtected)
            listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
            listItem.imageURL = LogoURLProvider.logoURL(for: paymentMethod, environment: apiContext.environment)
            listItem.trailingText = displayInformation.disclosureText
            listItem.subtitle = displayInformation.subtitle

            listItem.selectionHandler = { [unowned self] in
                guard !(paymentMethod is OrderPaymentMethod) else { return }
                self.delegate?.didSelect(paymentMethod, in: self)
            }
            
            return listItem
        }

        let sections: [ListSection] = paymentMethodSections.map {
            ListSection(header: $0.header,
                        items: $0.paymentMethods.map(item(for:)),
                        footer: $0.footer)
        }
        
        let listViewController = ListViewController(style: style)
        listViewController.title = localizedString(.paymentMethodsTitle, localizationParameters)
        listViewController.sections = sections
        
        return listViewController
    }()

    // MARK: - Cancellable

    internal func didCancel() {
        onCancel?()
    }
    
    // MARK: - Localization
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    // MARK: - Loading
    
    /// Starts a loading animation next to the list item of the provided component.
    ///
    /// - Parameter component: The component for which to start a loading animation.
    internal func startLoading(for component: PaymentComponent) {
        let allPaymentMethods = paymentMethodSections.map(\.paymentMethods).flatMap { $0 }
        
        guard let index = allPaymentMethods.firstIndex(where: { $0.type == component.paymentMethod.type }) else {
            return
        }
        
        let allListItems = listViewController.sections.flatMap(\.items)
        
        listViewController.startLoading(for: allListItems[index])
    }
    
    /// :nodoc:
    internal func stopLoading() {
        listViewController.stopLoading()
    }
    
}

/// Defines the methods a delegate of the payment method list component should implement.
internal protocol PaymentMethodListComponentDelegate: AnyObject {
    
    /// Invoked when a component was selected in the payment method list.
    ///
    /// - Parameters:
    ///   - component: The component that has been selected.
    ///   - paymentMethodListComponent: The payment method list component in which the component was selected.
    func didSelect(_ paymentMethod: PaymentMethod, in paymentMethodListComponent: PaymentMethodListComponent)
    
}
