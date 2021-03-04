//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that presents a list of items for each payment method with a component.
internal final class PaymentMethodListComponent: ComponentLoader, PresentableComponent, Localizable {
    
    /// The components that are displayed in the list.
    internal let components: SectionedComponents
    
    /// The delegate of the payment method list component.
    internal weak var delegate: PaymentMethodListComponentDelegate?
    
    /// Describes the component's UI style.
    internal let style: ListComponentStyle
    
    /// Initializes the list component.
    ///
    /// - Parameter components: The components to display in the list.
    /// - Parameter style: The component's UI style.
    internal init(components: SectionedComponents, style: ListComponentStyle = ListComponentStyle()) {
        self.components = components
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
            listItem.imageURL = LogoURLProvider.logoURL(for: component.paymentMethod, environment: environment)
            listItem.subtitle = displayInformation.subtitle
            listItem.showsDisclosureIndicator = showsDisclosureIndicator
            listItem.selectionHandler = { [unowned self, unowned component] in
                self.delegate?.didSelect(component, in: self)
            }
            
            return listItem
        }
        
        let storedSection = ListSection(items: components.stored.map(item(for:)))
        let regularSectionTitle = components.stored.isEmpty ? nil : ADYLocalizedString("adyen.paymentMethods.otherMethods",
                                                                                       localizationParameters)
        let regularSection = ListSection(title: regularSectionTitle,
                                         items: components.regular.map(item(for:)))
        
        let listViewController = ListViewController(style: style)
        listViewController.title = ADYLocalizedString("adyen.paymentMethods.title", localizationParameters)
        listViewController.sections = [storedSection, regularSection]
        
        return listViewController
    }()
    
    // MARK: - Localization
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    // MARK: - Loading
    
    /// Starts a loading animation next to the list item of the provided component.
    ///
    /// - Parameter component: The component for which to start a loading animation.
    internal func startLoading(for component: PaymentComponent) {
        let allListItems = listViewController.sections.flatMap(\.items)
        let allComponents = [components.stored, components.regular].flatMap { $0 }
        
        guard let index = allComponents.firstIndex(where: { $0 === component }) else {
            return
        }
        
        listViewController.startLoading(for: allListItems[index])
    }
    
    /// :nodoc:
    internal func stopLoading(completion: (() -> Void)?) {
        listViewController.stopLoading()
        completion?()
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
