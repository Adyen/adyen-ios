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
    internal let apiContext: AnyAPIContext
    
    /// The components that are displayed in the list.
    internal let componentSections: [ComponentsSection]
    
    /// The delegate of the payment method list component.
    internal weak var delegate: PaymentMethodListComponentDelegate?

    /// Call back when the list is dismissed.
    internal var onCancel: (() -> Void)?
    
    /// Describes the component's UI style.
    internal let style: ListComponentStyle
    
    /// Initializes the list component.
    ///
    /// - Parameter components: The components to display in the list.
    /// - Parameter style: The component's UI style.
    internal init(apiContext: AnyAPIContext,
                  components: [ComponentsSection],
                  style: ListComponentStyle = ListComponentStyle()) {
        self.apiContext = apiContext
        self.componentSections = components
        self.style = style
    }
    
    // MARK: - View Controller
    
    /// :nodoc:
    internal var viewController: UIViewController { listViewController }

    private let brandProtectedComponents: Set = ["applepay"]
    
    internal lazy var listViewController: ListViewController = {
        func item(for component: PaymentComponent) -> ListItem {
            let showsDisclosureIndicator = (component as? PresentableComponent)?.requiresModalPresentation == true
            
            let displayInformation = component.paymentMethod.localizedDisplayInformation(using: localizationParameters)
            let isProtected = brandProtectedComponents.contains(component.paymentMethod.type)
            let listItem = ListItem(title: displayInformation.title,
                                    style: style.listItem,
                                    canModifyIcon: !isProtected)
            listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
            listItem.imageURL = LogoURLProvider.logoURL(for: component.paymentMethod, environment: apiContext.environment)
            listItem.trailingText = displayInformation.disclosureText
            listItem.subtitle = displayInformation.subtitle
            listItem.showsDisclosureIndicator = showsDisclosureIndicator
            listItem.selectionHandler = { [unowned self, unowned component] in
                guard !(component is AlreadyPaidPaymentComponent) else { return }
                self.delegate?.didSelect(component, in: self)
            }
            
            return listItem
        }

        let sections: [ListSection] = componentSections.map {
            ListSection(header: $0.header,
                        items: $0.components.map(item(for:)),
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
        let allListItems = listViewController.sections.flatMap(\.items)
        let allComponents = componentSections.map(\.components).flatMap { $0 }
        
        guard let index = allComponents.firstIndex(where: { $0 === component }) else {
            return
        }
        
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
    func didSelect(_ component: PaymentComponent, in paymentMethodListComponent: PaymentMethodListComponent)
    
}
