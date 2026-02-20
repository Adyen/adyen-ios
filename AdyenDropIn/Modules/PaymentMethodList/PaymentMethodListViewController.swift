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

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var headerView: PaymentMethodListHeaderView = {
        let view = PaymentMethodListHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var listViewController: ListViewController = {
        var style = ListComponentStyle()
        
        style.listItem.title = TextStyle(
            font: .systemFont(ofSize: 17, weight: .regular),
            color: .label,
            textAlignment: .natural
        )
        style.listItem.subtitle = TextStyle(
            font: .systemFont(ofSize: 13, weight: .regular),
            color: .secondaryLabel,
            textAlignment: .natural
        )
        style.listItem.image = ImageStyle(
            borderColor: UIColor.separator,
            borderWidth: 1.0 / UIScreen.main.nativeScale,
            cornerRadius: 6.0,
            clipsToBounds: true,
            contentMode: .scaleAspectFit
        )
        
        style.sectionHeader.title = TextStyle(
            font: .systemFont(ofSize: 13, weight: .regular),
            color: .secondaryLabel,
            textAlignment: .natural
        )
        style.sectionHeader.trailingButton = ButtonStyle(
            title: TextStyle(
                font: .systemFont(ofSize: 17, weight: .regular),
                color: UIColor.Adyen.defaultBlue
            ),
            cornerRounding: .none,
            background: .clear
        )
        
        return ListViewController(style: style)
    }()

    // MARK: - Properties

    private var viewModel: PaymentMethodListViewModel
    private var cancellables = Set<AnyCancellable>()
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private var tableViewContentSizeObservation: NSKeyValueObservation?

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
        view.backgroundColor = .systemBackground
        viewModel.didLoad()
        isModalInPresentation = true
        setupNavigationItem()
        setupScrollView()
        setupHeaderView()
        setupListViewController()
        observeState()
    }

    // MARK: - Private

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeaderView() {
        contentStackView.addArrangedSubview(headerView)
        
        let headerViewModel = PaymentMethodListHeaderViewModel(
            amount: viewModel.formattedAmount,
            subtitle: viewModel.subtitle,
            showApplePayButton: viewModel.showApplePayButton,
            onApplePayTap: { [weak self] in
                self?.viewModel.selectApplePay()
            }
        )
        headerView.configure(with: headerViewModel)
    }

    private func setupListViewController() {
        listViewController.willMove(toParent: self)
        addChild(listViewController)
        contentStackView.addArrangedSubview(listViewController.view)
        listViewController.didMove(toParent: self)
        
        listViewController.tableView.isScrollEnabled = false
        
        tableViewHeightConstraint = listViewController.view.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        tableViewContentSizeObservation = listViewController.tableView.observe(\.contentSize, options: [.new]) { [weak self] tableView, _ in
            self?.tableViewHeightConstraint?.constant = tableView.contentSize.height
        }
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
