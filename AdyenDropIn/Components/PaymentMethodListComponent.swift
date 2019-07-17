//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that presents a list of items for each payment method with a component.
internal final class PaymentMethodListComponent: PresentableComponent {
    
    /// The components that are displayed in the list.
    internal let components: SectionedComponents
    
    /// The delegate of the payment method list component.
    internal weak var delegate: PaymentMethodListComponentDelegate?
    
    /// Initializes the list component.
    ///
    /// - Parameter components: The components to display in the list.
    internal init(components: SectionedComponents) {
        self.components = components
    }
    
    // MARK: - View Controller
    
    /// :nodoc:
    internal lazy var viewController: UIViewController = {
        listViewController
    }()
    
    private lazy var listViewController: ListViewController = {
        func item(for component: PaymentComponent) -> ListItem {
            let showsDisclosureIndicator = (component as? PresentableComponent)?.preferredPresentationMode == .push
            
            var listItem = ListItem(title: component.paymentMethod.displayInformation.title)
            listItem.imageURL = LogoURLProvider.logoURL(for: component.paymentMethod, environment: environment)
            listItem.subtitle = component.paymentMethod.displayInformation.subtitle
            listItem.showsDisclosureIndicator = showsDisclosureIndicator
            listItem.selectionHandler = { [unowned self, unowned component] in
                self.delegate?.didSelect(component, in: self)
            }
            
            return listItem
        }
        
        let storedSection = ListSection(items: components.stored.map(item(for:)))
        let regularSectionTitle = components.stored.isEmpty ? nil : ADYLocalizedString("adyen.paymentMethods.otherMethods")
        let regularSection = ListSection(title: regularSectionTitle,
                                         items: components.regular.map(item(for:)))
        
        let listViewController = ListViewController()
        listViewController.title = ADYLocalizedString("adyen.paymentMethods.title")
        listViewController.sections = [storedSection, regularSection]
        
        return listViewController
    }()
    
    // MARK: - Loading
    
    /// Starts a loading animation next to the list item of the provided component.
    ///
    /// - Parameter component: The component for which to start a loading animation.
    internal func startLoading(for component: PaymentComponent) {
        let allListItems = listViewController.sections.flatMap { $0.items }
        let allComponents = [components.stored, components.regular].flatMap { $0 }
        
        guard let index = allComponents.firstIndex(where: { $0 === component }) else {
            return
        }
        
        listViewController.startLoading(for: allListItems[index])
    }
    
    /// :nodoc:
    internal func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
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
