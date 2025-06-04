//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import UIKit

internal protocol ComponentViewModelProtocol {
    var view: UIViewController { get }
    var isRoot: Bool { get }
    func didCancel()
}

internal class ComponentViewModel: ComponentViewModelProtocol {

    // MARK: - Properties

    private let component: PresentableComponent
    internal let isRoot: Bool
    private let cancelHandler: ((_ isRoot: Bool) -> Void)?

    // MARK: - Initializers

    internal init(
        component: PresentableComponent,
        isRoot: Bool,
        cancelHandler: ((Bool) -> Void)?
    ) {
        self.component = component
        self.isRoot = isRoot
        self.cancelHandler = cancelHandler
    }

    // MARK: - Public

    internal var view: UIViewController {
        component.viewController
    }

    internal func didCancel() {
        cancelHandler?(isRoot)
    }
}

/// View controller with a custom navigation bar for DropIn.

internal final class ComponentViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ComponentViewModelProtocol
    internal weak var delegate: ViewControllerDelegate?

    // MARK: - Initializing

    internal init(viewModel: ComponentViewModelProtocol) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: Bundle(for: ComponentViewController.self))
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
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        componentView.resignFirstResponder()
        viewModel.didCancel()
    }

    private func setupComponentView() {
        componentView.willMove(toParent: self)
        addChild(componentView)
        view.addSubview(componentView.view)
        componentView.didMove(toParent: self)
        setupLayout()
    }

    // MARK: - Private

    private var componentView: UIViewController {
        viewModel.view
    }

    private func setupLayout() {
        componentView.view.adyen.anchor(inside: view)
    }

    private func setupNavigationItem() {
        navigationItem.title = "Checkout"

        if viewModel.isRoot { setupCancelButton() }
    }

    private func setupCancelButton() {
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        navigationItem.rightBarButtonItem = cancelButton
    }

    @objc private func cancelButtonTapped() {
        navigationController?.dismiss(animated: true)
    }
}
