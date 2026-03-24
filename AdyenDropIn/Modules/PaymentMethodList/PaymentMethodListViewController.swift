//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenUI
import Combine
import Foundation
import UIKit

internal class PaymentMethodListViewController: UIViewController {

    private enum Layout {
        static let headerViewBottomMargin: CGFloat = 32
    }

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return stackView
    }()
    
    private lazy var headerView: PaymentMethodListHeaderView = {
        let headerViewModel = PaymentMethodListHeaderViewModel(
            amount: viewModel.formattedAmount,
            subtitle: viewModel.subtitle,
            applePayButtonState: viewModel.applePayButtonState,
            theme: viewModel.theme
        )

        let view = PaymentMethodListHeaderView(viewModel: headerViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var paymentMethodSectionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var loadingOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = theme.colors.background.withAlphaComponent(0.6)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Properties

    private let viewModel: PaymentMethodListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var theme: AdyenTheme {
        viewModel.theme
    }

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
        view.backgroundColor = theme.colors.background
        viewModel.didLoad()
        isModalInPresentation = true
        setupNavigationItem()
        setupScrollView()
        setupHeaderView()
        setupPaymentMethodSectionsStackView()
        setupLoadingOverlay()
        observeState()
    }

    // MARK: - Private

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupHeaderView() {
        contentStackView.addArrangedSubview(headerView)
        contentStackView.setCustomSpacing(Layout.headerViewBottomMargin, after: headerView)
    }

    private func setupPaymentMethodSectionsStackView() {
        contentStackView.addArrangedSubview(paymentMethodSectionsStackView)
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.title
        navigationItem.largeTitleDisplayMode = .never
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
                case .idle:
                    self?.hideLoadingOverlay()
                case .loading:
                    self?.showLoadingOverlay()
                }
            }.store(in: &cancellables)
    }

    private func reload(with sections: [PaymentMethodSection]) {
        clearList()
        populateList(with: sections)
    }
    
    // MARK: - Payment Methods Stack View Management
    
    private func clearList() {
        paymentMethodSectionsStackView.arrangedSubviews.forEach { view in
            paymentMethodSectionsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
    
    private func populateList(with sections: [PaymentMethodSection]) {
        sections.forEach { section in
            let sectionView = PaymentMethodSectionView(section: section)
            paymentMethodSectionsStackView.addArrangedSubview(sectionView)
        }
    }
    
    // MARK: - Loading Overlay
    
    private func setupLoadingOverlay() {
        view.addSubview(loadingOverlayView)
        
        NSLayoutConstraint.activate([
            loadingOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showLoadingOverlay() {
        UIView.animate(withDuration: 0.2) {
            self.loadingOverlayView.alpha = 1
        }
    }
    
    private func hideLoadingOverlay() {
        UIView.animate(withDuration: 0.2) {
            self.loadingOverlayView.alpha = 0
        }
    }
}
