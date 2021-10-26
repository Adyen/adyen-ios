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
    internal private(set) var componentSections: [ComponentsSection]
    
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
    internal init(apiContext: APIContext,
                  components: [ComponentsSection],
                  style: ListComponentStyle = ListComponentStyle()) {
        self.apiContext = apiContext
        self.componentSections = components
        self.style = style
    }
    
    internal func reload(with components: [ComponentsSection]) {
        componentSections = components
        listViewController.reload(newSections: createListSections())
    }
    
    // MARK: - View Controller
    
    /// :nodoc:
    internal var viewController: UIViewController { listViewController }

    private let brandProtectedComponents: Set = ["applepay"]
    
    internal lazy var listViewController: ListViewController = createListViewController()
    
    private func createListViewController() -> ListViewController {
        let listViewController = ListViewController(style: style)
        listViewController.title = localizedString(.paymentMethodsTitle, localizationParameters)
        listViewController.reload(newSections: createListSections())
        
        return listViewController
    }
    
    private func createListSections() -> [ListSection] {
        func item(for component: PaymentComponent) -> ListItem {
            let displayInformation = component.paymentMethod.localizedDisplayInformation(using: localizationParameters)
            let isProtected = brandProtectedComponents.contains(component.paymentMethod.type)
            let listItem = ListItem(title: displayInformation.title,
                                    style: style.listItem,
                                    canModifyIcon: !isProtected)
            listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
            listItem.imageURL = LogoURLProvider.logoURL(for: component.paymentMethod, environment: apiContext.environment)
            listItem.trailingText = displayInformation.disclosureText
            listItem.subtitle = displayInformation.subtitle
            listItem.selectionHandler = { [weak self, weak component] in
                guard let self = self, let component = component else { return }
                guard !(component is AlreadyPaidPaymentComponent) else { return }
                self.delegate?.didSelect(component, in: self)
            }
            
            listItem.deletionHandler = { [weak self, weak component] completion in
                guard let self = self, let component = component else { return }
                guard let paymentMethod = component.paymentMethod as? StoredPaymentMethod else { return }
                self.delegate?.didDelete(paymentMethod, in: self, completion: completion)
            }
            
            return listItem
        }

        return componentSections.map {
            ListSection(header: $0.header,
                        items: $0.components.map(item(for:)),
                        footer: $0.footer,
                        editingStyle: $0.editingStyle)
        }
    }

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
    
    /// Invoked when a component was deleted in the payment method list.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method that has been deleted.
    ///   - paymentMethodListComponent: The payment method list component in which the component was selected.
    func didDelete(_ paymentMethod: StoredPaymentMethod, in paymentMethodListComponent: PaymentMethodListComponent, completion: @escaping Completion<Bool>)
    
}
