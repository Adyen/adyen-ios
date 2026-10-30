//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Combine
import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

internal class ComponentContainerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ComponentContainerViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private var theme: CheckoutTheme {
        viewModel.theme
    }
    
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
        setNavigationLock(active: false)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
    }
        
    private func setupLayout() {
        componentViewController.view.adyen.anchor(inside: view)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = componentViewController.title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func observePaymentProgress() {
        viewModel.paymentInProgressPublisher
            .removeDuplicates()
            .sink { [weak self] isPaymentInProgress in
                guard let self, navigationController?.topViewController === self else { return }
                setNavigationLock(active: isPaymentInProgress)
            }
            .store(in: &cancellables)
    }

    private func setNavigationLock(active isActive: Bool) {
        navigationController?.navigationBar.isUserInteractionEnabled = !isActive
        navigationController?.popGestureRecognizers.forEach { $0.isEnabled = !isActive }
    }
}

private extension UINavigationController {
    var popGestureRecognizers: [UIGestureRecognizer] {
        var recognizers = [interactivePopGestureRecognizer].compactMap { $0 }
        #if compiler(>=6.2)
            if #available(iOS 26.0, *), let contentPopGestureRecognizer = interactiveContentPopGestureRecognizer {
                recognizers.append(contentPopGestureRecognizer)
            }
        #endif
        return recognizers
    }
}
