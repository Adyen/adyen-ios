//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Adyen

internal class GenericPaymentMethodViewModel: ObservableObject {

    internal enum State {
        case idle
        case loading
    }

    // MARK: - Properties

    private let paymentComponent: PaymentComponent
    private let dropInFlowManager: DropInFlowManaging
    internal weak var router: GenericPaymentMethodRouting?

    @Published var state: State = .idle

    // MARK: - Initializers

    internal init(
        paymentComponent: PaymentComponent,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.paymentComponent = paymentComponent
        self.dropInFlowManager = dropInFlowManager
    }

    internal var paymentMethodName: String {
        paymentComponent.paymentMethod.name
    }

}
