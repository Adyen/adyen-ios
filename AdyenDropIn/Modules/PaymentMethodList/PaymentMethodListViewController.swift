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

internal class PaymentMethodListViewController: UIViewController {

    // MARK: - UI elements

    private lazy var listViewController: ListViewController = {
        let style = ListComponentStyle()
        return ListViewController(style: style)
    }()

    // MARK: - Properties

    private let viewModel: PaymentMethodListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers

    internal init(
        viewModel: PaymentMethodListViewModelProtocol
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
        navigationItem.title = viewModel.title
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

    private func observeState() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case let .loaded(sections):
                    self?.reload(with: sections)
                case let .loading(paymentMethod):
                    self?.startLoading(for: paymentMethod)
                case .ready:
                    self?.stopLoading()
                }
            }.store(in: &cancellables)
    }

    private func startLoading(for paymentMethod: PaymentMethod) {
        let expectedIdentifier = viewModel.listItemIdentifier(for: paymentMethod)
        let listItem = listViewController.sections
            .flatMap(\.items)
            .first { $0.identifier == expectedIdentifier }
        listItem?.startLoading()
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
