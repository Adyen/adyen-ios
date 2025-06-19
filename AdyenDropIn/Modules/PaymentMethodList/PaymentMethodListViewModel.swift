//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

internal protocol PaymentMethodListRouterProtocol: AnyObject {
    func didLoad()
    func present(_ component: PaymentComponent)
    func delete(
        storedPaymentMethod: StoredPaymentMethod,
        completion: @escaping (Bool) -> Void
    )
}

internal protocol PaymentMethodListViewModelProtocol {
    var paymentMethodListView: UIViewController { get }
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol, PaymentMethodListComponentDelegate {

    // MARK: - Properties

    private weak var router: PaymentMethodListRouterProtocol?
    private let paymentMethodListComponent: PaymentMethodListComponent

    // MARK: - Initializers

    internal init(
        router: PaymentMethodListRouterProtocol,
        context: AdyenContext,
        componentManager: ComponentManager,
        style: ListComponentStyle,
        localizationParameters: LocalizationParameters?
    ) {
        self.router = router

        let components = componentManager.sections
        self.paymentMethodListComponent = PaymentMethodListComponent(
            context: context,
            components: components,
            style: style
        )
        self.paymentMethodListComponent.localizationParameters = localizationParameters
        self.paymentMethodListComponent.delegate = self
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var paymentMethodListView: UIViewController {
        paymentMethodListComponent.viewController
    }

    // MARK: - PaymentMethodListComponentDelegate

    internal func didLoad(
        _ paymentMethodListComponent: PaymentMethodListComponent
    ) {
        router?.didLoad()
    }

    internal func didSelect(
        _ component: any Adyen.PaymentComponent,
        in paymentMethodListComponent: PaymentMethodListComponent
    ) {
        router?.present(component)
    }

    internal func didDelete(
        _ paymentMethod: any Adyen.StoredPaymentMethod,
        in paymentMethodListComponent: PaymentMethodListComponent,
        completion: @escaping Adyen.Completion<Bool>
    ) {
        router?.delete(storedPaymentMethod: paymentMethod, completion: completion)
    }

    // MARK: - Private
}

internal class PaymentMethodListViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PaymentMethodListViewModelProtocol

    // MARK: - Initalizers

    internal init(viewModel: PaymentMethodListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        navigationItem.title = "2"

        setupPaymentMethodListView()
    }

    // MARK: - Private

    private func setupPaymentMethodListView() {
        let paymentMethodListView = viewModel.paymentMethodListView

        paymentMethodListView.willMove(toParent: self)
        addChild(paymentMethodListView)
        view.addSubview(paymentMethodListView.view)
        paymentMethodListView.didMove(toParent: self)
        paymentMethodListView.view.adyen.anchor(inside: view)
    }
}
