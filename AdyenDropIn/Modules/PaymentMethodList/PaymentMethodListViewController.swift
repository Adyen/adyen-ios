//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

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

        setupNavigationItem()
        setupPaymentMethodListView()

        // TODO: - Implement analytics
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

    private func setupNavigationItem() {
        navigationItem.title = viewModel.paymentMethodListView.title
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: viewModel,
            action: #selector(viewModel.cancel)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }
}
