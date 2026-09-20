//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation
import SafariServices
import UIKit

// sourcery:AutoMockable
@MainActor
internal protocol PaymentActionAssemblerProtocol {
    func resolvePaymentActionRouter(
        for action: Action,
        listener: PaymentActionRouterListener
    ) async -> Router?
}

@MainActor
internal struct PaymentActionAssembler: PaymentActionAssemblerProtocol {

    // MARK: - Properties

    private let dropInFlowManager: DropInFlowManaging

    // MARK: - Initializers

    internal init(dropInFlowManager: DropInFlowManaging) {
        self.dropInFlowManager = dropInFlowManager
    }

    // MARK: - PaymentActionAssemblerProtocol

    internal func resolvePaymentActionRouter(
        for action: Action,
        listener: PaymentActionRouterListener
    ) async -> Router? {
        guard let actionViewController = await dropInFlowManager.handle(action: action) else { return nil }

        let viewModel = PaymentActionViewModel(dropInFlowManager: dropInFlowManager)
        let router = PaymentActionRouter(
            viewController: rootViewController(for: actionViewController, viewModel: viewModel),
            viewModel: viewModel,
            listener: listener
        )
        viewModel.router = router
        return router
    }

    // MARK: - Private

    private func rootViewController(
        for actionViewController: UIViewController,
        viewModel: PaymentActionViewModelProtocol
    ) -> UIViewController {
        // Action components that manage their own navigation are used as-is,
        // to avoid embedding a web view inside another view.
        if actionViewController is SFSafariViewController || actionViewController is UINavigationController {
            return actionViewController
        }

        let paymentActionViewController = PaymentActionViewController(
            viewModel: viewModel,
            actionViewController: actionViewController
        )
        return UINavigationController(rootViewController: paymentActionViewController)
    }
}
