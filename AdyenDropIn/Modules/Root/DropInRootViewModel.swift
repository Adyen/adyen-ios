//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal class DropInRootAssembler {

    // MARK: - Properties

    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration

    // MARK: - Initalizers

    internal init(
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration
    ) {
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
    }

    // MARK: - Public

    internal func resolveDropInRootView() -> UIViewController {
        let componentManager = resolveComponentManager()
        let apiClient = resolveAPIClient()

        let viewModel = DropInRootViewModel(
            componentManager: componentManager,
            apiClient: apiClient,
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration
        )
        componentManager.presentationDelegate = viewModel

        let view = DropInRootViewController(viewModel: viewModel)
        return view
    }

    // MARK: - Private

    private func resolveComponentManager() -> ComponentManager {
        let componentManager = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            partialPaymentEnabled: false, // TODO: - Set partial payment flow
            order: nil,
            supportsEditingStoredPaymentMethods: false, // TODO: - Support editing stored PMs
            presentationDelegate: nil
        )

        return componentManager
    }

    private func resolveAPIClient() -> APIClientProtocol {
        let scheduler = SimpleScheduler(maximumCount: 3)
        let apiClient = APIClient(apiContext: context.apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()

        return apiClient
    }
}

internal protocol DropInRootViewModelProtocol {
    var rootViewController: UIViewController? { get }
}

internal class DropInRootViewModel: DropInRootViewModelProtocol {

    // MARK: - Properties

    private let componentManager: ComponentManager
    private let apiClient: APIClientProtocol
    private let paymentMethods: PaymentMethods
    private let context: AdyenContext
    private let configuration: DropInComponent.Configuration
    private let title: String?

    // MARK: - Initializers

    internal init(
        componentManager: ComponentManager,
        apiClient: APIClientProtocol,
        paymentMethods: PaymentMethods,
        context: AdyenContext,
        configuration: DropInComponent.Configuration,
        title: String? = nil
    ) {
        self.componentManager = componentManager
        self.apiClient = apiClient
        self.paymentMethods = paymentMethods
        self.context = context
        self.configuration = configuration
        self.title = title
    }

    // MARK: - DropInRootViewModelProtocol

    var rootViewController: UIViewController? {
        return nil
    }

    // MARK: - Private
}

extension DropInRootViewModel: PresentationDelegate {

    internal func present(component: any Adyen.PresentableComponent) {
        // TODO: -
    }
}

class DropInRootViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: DropInRootViewModelProtocol

    // MARK: - Initializers

    init(viewModel: DropInRootViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
