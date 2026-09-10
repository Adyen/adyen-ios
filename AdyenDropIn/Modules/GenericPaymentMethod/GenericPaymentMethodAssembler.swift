//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

@MainActor
internal protocol GenericPaymentMethodAssemblerProtocol {
    func resolveGenericPaymentMethodRouter(
        paymentComponent: PaymentComponent
    ) -> Router
}

@MainActor
internal struct GenericPaymentMethodAssembler: GenericPaymentMethodAssemblerProtocol {

    // MARK: - Properties

    private let dropInFlowManager: DropInFlowManaging

    // MARK: - GenericPaymentMethodAssemblerProtocol

    internal func resolveGenericPaymentMethodRouter(
        paymentComponent: PaymentComponent
    ) -> Router {
        let viewModel = GenericPaymentMethodViewModel(
            paymentComponent: paymentComponent,
            dropInFlowManager: dropInFlowManager
        )
        let genericPaymentMethodView = GenericPaymentMethodView(viewModel: viewModel)
        let genericPaymentMethodViewController = UIHostingController(rootView: genericPaymentMethodView)

        let router = GenericPaymentMethodRouter(viewController: genericPaymentMethodViewController)
        viewModel.router = router
        return router
    }

}
