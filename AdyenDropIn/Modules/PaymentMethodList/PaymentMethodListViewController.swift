//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Combine
import Foundation
import UIKit

/// Payment methods list related configurations.
public struct PaymentMethodListConfiguration {
    
    public init() { /* Empty initializer */ }
    
    /// Indicates whether to allow shoppers to disable/delete stored payment methods
    public var allowDisablingStoredPaymentMethods: Bool = false
}

internal class PaymentMethodListViewController: UIViewController {

    // MARK: - UI elements

    private lazy var listViewController: ListViewController = {
        let style = ListComponentStyle()
        let listViewController = ListViewController(style: style)
        listViewController.title = localizedString(.paymentMethodsTitle, localizationParameters)
        return listViewController
    }()

    // MARK: - Properties

    private var viewModel: PaymentMethodListViewModel
    private var cancellables = Set<AnyCancellable>()

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
        observeState()
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

    private func observeState() {
        viewModel.$state.sink { [weak self] state in
            switch state {
            case let .loaded(sections):
                self?.reload(with: sections)
            case let .loading(paymentMethod):
                self?.startLoading(for: paymentMethod)
            case .idle:
                self?.stopLoading()
            }
        }.store(in: &cancellables)
    }

    private func startLoading(for paymentMethod: PaymentMethod) {
        let listItems = listViewController.sections.flatMap(\.items)
        let paymentMethods = viewModel.paymentMethodSections.flatMap(\.paymentMethods)

        guard let index = paymentMethods.firstIndex(where: { $0 == paymentMethod }) else {
            return
        }

        listItems[index].startLoading()
    }

    private func stopLoading() {
        listViewController.stopLoading()
    }

    private func reload(with sections: [ListSection]) {
        listViewController.reload(newSections: sections)
    }
    
    internal func deleteComponent(at indexPath: IndexPath) {
        listViewController.deleteItem(at: indexPath)
    }

    // TODO: - Handle component deletion logic
    private func delete(component: PaymentComponent?, at indexPath: IndexPath, completion: @escaping Completion<Bool>) {
//        guard let component else { return }
//        guard let paymentMethod = component.paymentMethod as? StoredPaymentMethod else { return }
//        let completion: (Bool) -> Void = { [weak self] success in
//            defer {
//                completion(success)
//            }
//            guard success else { return }
//            // This is to prevent the merchant calling completion closure multiple times
//            guard let self else { return }
//            guard viewModel.componentSections[indexPath.section]
//                .components[indexPath.item]
//                .paymentMethod == paymentMethod else { return }
//            self.deleteComponent(at: indexPath)
//        }
//        viewModel.delete(paymentMethod, completion: completion)
    }
}

private extension [PaymentMethodsSection] {
    mutating func deleteItem(at indexPath: IndexPath) {
        self[indexPath.section].paymentMethods.remove(at: indexPath.item)
        self = self.filter { $0.paymentMethods.isEmpty == false }
    }
}
