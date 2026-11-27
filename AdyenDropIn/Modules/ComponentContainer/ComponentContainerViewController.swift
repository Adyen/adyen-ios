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

internal class ComponentContainerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ComponentContainerViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private var theme: CheckoutTheme {
        viewModel.theme
    }

    internal private(set) lazy var cancelButtonItem = UIBarButtonItem(
        systemItem: .cancel,
        primaryAction: UIAction { [weak self] _ in
            self?.viewModel.cancelDropIn()
        }
    )
    
    // MARK: - Initializers
    
    internal init(viewModel: ComponentContainerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle(for: ComponentContainerViewController.self))
        isModalInPresentation = true
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupComponentView()
        setupNavigationItem()
        applyTheme()
        observePaymentProgress()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationLock(active: false)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let isRemovedFromNavigation = navigationController?.viewControllers.contains(self) != true
        guard isRemovedFromNavigation || isBeingDismissed || navigationController?.isBeingDismissed == true else { return }
        componentViewController.resignFirstResponder()
        viewModel.cancel()
    }
    
    // MARK: - Internal
    
    internal var componentViewController: UIViewController {
        viewModel.componentViewController
    }
    
    // MARK: - Private

    private func applyTheme() {
        view.backgroundColor = theme.colors.background
    }

    private func setupComponentView() {
        componentViewController.willMove(toParent: self)
        addChild(componentViewController)
        view.addSubview(componentViewController.view)
        componentViewController.didMove(toParent: self)
        setupLayout()
        // The navigation bar tracks the container, so adopt the scroll view the component declares, e.g. to collapse a large title.
        setContentScrollView(componentViewController.contentScrollView(for: .top), for: .top)
    }
        
    private func setupLayout() {
        componentViewController.view.adyen.anchor(inside: view)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = componentViewController.title
        let componentNavigationItem = componentViewController.navigationItem
        // Keep the title inline when the component asks for it, otherwise show it large.
        navigationItem.largeTitleDisplayMode = componentNavigationItem.largeTitleDisplayMode == .never ? .never : .always
        navigationController?.navigationBar.prefersLargeTitles = true
        // The navigation bar shows the container's item, so adopt the component's search controller.
        if let searchController = componentNavigationItem.searchController {
            navigationItem.searchController = searchController
            navigationItem.preferredSearchBarPlacement = componentNavigationItem.preferredSearchBarPlacement
            navigationItem.hidesSearchBarWhenScrolling = componentNavigationItem.hidesSearchBarWhenScrolling
            #if compiler(>=6.2)
                if #available(iOS 26.0, *) {
                    navigationItem.searchBarPlacementAllowsToolbarIntegration =
                        componentNavigationItem.searchBarPlacementAllowsToolbarIntegration
                }
            #endif
            definesPresentationContext = true
        }
        // Adopt the component's bar appearance too, for example a solid background behind its search bar.
        navigationItem.standardAppearance = componentNavigationItem.standardAppearance
        navigationItem.scrollEdgeAppearance = componentNavigationItem.scrollEdgeAppearance
        if viewModel.isDropInRoot {
            navigationItem.leftBarButtonItem = cancelButtonItem
        }
    }

    private func observePaymentProgress() {
        viewModel.paymentInProgressPublisher
            .removeDuplicates()
            .sink { [weak self] isPaymentInProgress in
                guard let self else { return }
                cancelButtonItem.isEnabled = !isPaymentInProgress
                guard navigationController?.topViewController === self else { return }
                navigationController?.setNavigationLock(active: isPaymentInProgress)
            }
            .store(in: &cancellables)
    }

}
