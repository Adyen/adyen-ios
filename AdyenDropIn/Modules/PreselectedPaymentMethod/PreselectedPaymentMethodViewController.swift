//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

internal class PreselectedPaymentMethodViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PreselectedPaymentMethodViewModelProtocol

    // MARK: - Initializers

    internal init(viewModel: PreselectedPaymentMethodViewModelProtocol) {
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
        setupPaymentMethodView()
        setupNavigationItem()
    }

    // MARK: - Private

    private func setupPaymentMethodView() {
        let paymentMethodView = viewModel.paymentMethodView

        paymentMethodView.willMove(toParent: self)
        addChild(paymentMethodView)
        view.addSubview(paymentMethodView.view)
        paymentMethodView.didMove(toParent: self)
        paymentMethodView.view.adyen.anchor(inside: view)
    }

    private func setupNavigationItem() {
        navigationItem.title = viewModel.paymentMethodView.title
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
}
