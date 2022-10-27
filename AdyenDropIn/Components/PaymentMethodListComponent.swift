//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// Payment methods list related configurations.
public struct PaymentMethodListConfiguration {
    
    public init() { /* Empty initializer */ }
    
    /// Indicates whether to allow shoppers to disable/delete stored payment methods
    public var allowDisablingStoredPaymentMethods: Bool = false
}

/// A component that presents a list of items for each payment method with a component.
internal final class PaymentMethodListComponent: ComponentLoader, PresentableComponent, Localizable, Cancellable {
    
    internal let context: AdyenContext
    
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
    /// - Parameter context: The context object for this component.
    /// - Parameter components: The components to display in the list.
    /// - Parameter style: The component's UI style.
    internal init(context: AdyenContext,
                  components: [ComponentsSection],
                  style: ListComponentStyle = ListComponentStyle()) {
        self.context = context
        self.componentSections = components
        self.style = style
    }
    
    internal func reload(with components: [ComponentsSection]) {
        componentSections = components
        listViewController.reload(newSections: createListSections())
    }
    
    internal func deleteComponent(at indexPath: IndexPath) {
        componentSections.deleteItem(at: indexPath)
        listViewController.deleteItem(at: indexPath)
    }
    
    // MARK: - View Controller
    
    internal var viewController: UIViewController { listViewController }

    private let brandProtectedComponents: Set<PaymentMethodType> = [.applePay]
    
    internal lazy var listViewController: ListViewController = createListViewController()
    
    private func createListViewController() -> ListViewController {
        let listViewController = ListViewController(style: style)
        listViewController.delegate = self
        listViewController.title = localizedString(.paymentMethodsTitle, localizationParameters)
        listViewController.reload(newSections: createListSections())

        return listViewController
    }
    
    private func createListSections() -> [ListSection] {
        componentSections.map { section in
            ListSection(header: section.header,
                        items: section.components.map(item(for:)),
                        footer: section.footer)
        }
    }
    
    private func item(for component: PaymentComponent) -> ListItem {
        let displayInformation = component.paymentMethod.displayInformation(using: localizationParameters)
        let isProtected = brandProtectedComponents.contains(component.paymentMethod.type)
        let listItem = ListItem(title: displayInformation.title,
                                style: style.listItem,
                                canModifyIcon: !isProtected)
        listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
        listItem.imageURL = LogoURLProvider.logoURL(withName: displayInformation.logoName,
                                                    environment: context.apiContext.environment)
        listItem.trailingText = displayInformation.disclosureText
        listItem.subtitle = displayInformation.subtitle
        listItem.selectionHandler = { [weak self, weak component] in
            guard let self = self, let component = component else { return }
            guard !(component is AlreadyPaidPaymentComponent) else { return }
            self.delegate?.didSelect(component, in: self)
        }
        
        listItem.deletionHandler = { [weak self, weak component] indexPath, completion in
            self?.delete(component: component, at: indexPath, completion: completion)
        }
        
        return listItem
    }
    
    private func delete(component: PaymentComponent?, at indexPath: IndexPath, completion: @escaping Completion<Bool>) {
        guard let component = component else { return }
        guard let paymentMethod = component.paymentMethod as? StoredPaymentMethod else { return }
        let completion: (Bool) -> Void = { [weak self] success in
            defer {
                completion(success)
            }
            guard success else { return }
            // This is to prevent the merchant calling completion closure multiple times
            guard let self = self else { return }
            guard self.componentSections[indexPath.section]
                .components[indexPath.item]
                .paymentMethod == paymentMethod else { return }
            self.deleteComponent(at: indexPath)
        }
        delegate?.didDelete(paymentMethod, in: self, completion: completion)
    }

    // MARK: - Cancellable

    internal func didCancel() {
        onCancel?()
    }
    
    // MARK: - Localization
    
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
    
    internal func stopLoading() {
        listViewController.stopLoading()
    }

    // MARK: - Private

    private func sendTelemetryEvent() {
        context.analyticsProvider.sendTelemetryEvent(flavor: .dropIn(paymentMethods: []))
    }
}

extension PaymentMethodListComponent: ViewControllerDelegate {

    func viewDidLoad(viewController: UIViewController) {
        delegate?.didLoad(self)
    }

    func viewWillAppear(viewController: UIViewController) { /* Empty implementation */ }

    func viewDidAppear(viewController: UIViewController) { /* Empty implementation */ }
}

/// Defines the methods a delegate of the payment method list component should implement.
internal protocol PaymentMethodListComponentDelegate: AnyObject {

    /// Tells the delegate the payment method list component has been loaded.
    ///
    /// - Parameters:
    ///   - paymentMethodListComponent: The payment method list component in which the component was selected.
    func didLoad(_ paymentMethodListComponent: PaymentMethodListComponent)
    
    /// Invoked when a component was selected in the payment method list.
    ///
    /// - Parameters:
    ///   - component: The component that has been selected.
    ///   - paymentMethodListComponent: The payment method list component in which the component was selected.
    func didSelect(_ component: PaymentComponent, in paymentMethodListComponent: PaymentMethodListComponent)
    
    /// Invoked when the shopper wants to delete a stored payment method from the payment method list.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method that has been deleted.
    ///   - paymentMethodListComponent: The payment method list component in which the component was selected.
    ///   - completion: The completion block,
    ///   it must be invoked by the delegate when the stored payment method is successfully deleted.
    func didDelete(_ paymentMethod: StoredPaymentMethod,
                   in paymentMethodListComponent: PaymentMethodListComponent,
                   completion: @escaping Completion<Bool>)
}

private extension Array where Element == ComponentsSection {
    mutating func deleteItem(at indexPath: IndexPath) {
        self[indexPath.section].components.remove(at: indexPath.item)
        self = self.filter { $0.components.isEmpty == false }
    }
}
