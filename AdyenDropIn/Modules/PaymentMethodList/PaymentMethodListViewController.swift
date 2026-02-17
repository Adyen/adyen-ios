//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

/// Payment methods list related configurations.
public struct PaymentMethodListConfiguration {
    
    public init() { /* Empty initializer */ }
    
    /// Indicates whether to allow shoppers to disable/delete stored payment methods
    public var allowDisablingStoredPaymentMethods: Bool = false
}

internal class PaymentMethodListViewController: UIViewController, ComponentLoader {

    // MARK: - UI elements

    private lazy var listViewController: ListViewController = {
        let style = ListComponentStyle()
        let listViewController = ListViewController(style: style)
        listViewController.title = localizedString(.paymentMethodsTitle, localizationParameters)
        listViewController.reload(newSections: createListSections())
        return listViewController
    }()

    // MARK: - Properties

    private var viewModel: PaymentMethodListViewModelProtocol

    // MARK: - Initializers

    internal init(
        viewModel: PaymentMethodListViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        viewModel.didLoad()
        isModalInPresentation = true
        setupNavigationItem()
        setupListViewController()
    }

    // MARK: - Private

    private func setupListViewController() {
        listViewController.willMove(toParent: self)
        addChild(listViewController)
        view.addSubview(listViewController.view)
        listViewController.didMove(toParent: self)
        listViewController.view.adyen.anchor(inside: view)
    }

    private func setupNavigationItem() {
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        setupCancelButton()
    }

    private func setupCancelButton() {
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }

    @objc private func cancelTapped() {
        viewModel.cancel()
    }

    private var localizationParameters: LocalizationParameters? {
        viewModel.localizationParameters
    }

    // MARK: - OLD STUFF

    internal func reload(with components: [ComponentsSection]) {
        viewModel.componentSections = components
        listViewController.reload(newSections: createListSections())
    }
    
    internal func deleteComponent(at indexPath: IndexPath) {
        viewModel.componentSections.deleteItem(at: indexPath)
        listViewController.deleteItem(at: indexPath)
    }

    private let brandProtectedComponents: Set<PaymentMethodType> = [.applePay]

    private func createListSections() -> [ListSection] {
        viewModel.componentSections.map { section in
            ListSection(
                header: section.header,
                items: section.components.map(item(for:)),
                footer: section.footer
            )
        }
    }
    
    private func item(for component: PaymentComponent) -> ListItem {
        let displayInformation = component.paymentMethod.displayInformation(using: localizationParameters)
        let isProtected = brandProtectedComponents.contains(component.paymentMethod.type)
        let context = viewModel.context
        let logoUrlProvider = LogoURLProvider(environment: context.apiContext.environment)
        let imageURL = logoUrlProvider.logoURL(withName: displayInformation.logoName)
        
        let listItem = ListItem(
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            icon: .init(
                url: imageURL,
                canBeModified: !isProtected
            ),
            trailingInfo: displayInformation.trailingInfo?.forListItem(urlProvider: logoUrlProvider),
            style: .init(),
            accessibilityLabel: displayInformation.accessibilityLabel
        )
        listItem.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: listItem.title
        )
        listItem.selectionHandler = { [weak self, weak component] in
            guard let self, let component else { return }
            guard !(component is AlreadyPaidPaymentComponent) else { return }
            viewModel.select(component)
        }
        listItem.deletionHandler = { [weak self, weak component] indexPath, completion in
            self?.delete(component: component, at: indexPath, completion: completion)
        }
        
        return listItem
    }
    
    private func delete(component: PaymentComponent?, at indexPath: IndexPath, completion: @escaping Completion<Bool>) {
        guard let component else { return }
        guard let paymentMethod = component.paymentMethod as? StoredPaymentMethod else { return }
        let completion: (Bool) -> Void = { [weak self] success in
            defer {
                completion(success)
            }
            guard success else { return }
            // This is to prevent the merchant calling completion closure multiple times
            guard let self else { return }
            guard viewModel.componentSections[indexPath.section]
                .components[indexPath.item]
                .paymentMethod == paymentMethod else { return }
            self.deleteComponent(at: indexPath)
        }
        viewModel.delete(paymentMethod, completion: completion)
    }

    // MARK: - Loading
    
    /// Starts a loading animation next to the list item of the provided component.
    ///
    /// - Parameter component: The component for which to start a loading animation.
    internal func startLoading(for component: PaymentComponent) {
        let allListItems = listViewController.sections.flatMap(\.items)
        let allComponents = viewModel.componentSections.map(\.components).flatMap { $0 }
        
        guard let index = allComponents.firstIndex(where: { $0 === component }) else {
            return
        }
        
        allListItems[index].startLoading()
    }
    
    internal func stopLoading() {
        listViewController.stopLoading()
    }
}

private extension [ComponentsSection] {
    mutating func deleteItem(at indexPath: IndexPath) {
        self[indexPath.section].components.remove(at: indexPath.item)
        self = self.filter { $0.components.isEmpty == false }
    }
}

private extension DisplayInformation.TrailingInfoType {
    
    func forListItem(urlProvider: LogoURLProvider) -> ListItem.TrailingInfoType {
        switch self {
        case let .text(string):
            return .text(string)
        case let .logos(logoNames, trailingText):
            return .logos(urls: logoNames.map { urlProvider.logoURL(withName: $0) }, trailingText: trailingText)
        }
    }
}
