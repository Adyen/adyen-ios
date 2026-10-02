//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct StoredPaymentMethodManagementRouterTests {

    @Test
    func rootViewController_returnsInjectedRootViewController() {
        let rootViewController = UIViewController()
        let sut = makeSUT(rootViewController: rootViewController)

        #expect(sut.rootViewController === rootViewController)
    }

    @Test
    func didRemove_forwardsPaymentMethodToListener() {
        let listener = StoredPaymentMethodManagementListenerMock()
        let sut = makeSUT(listener: listener)
        let paymentMethod = StoredPaymentMethodMock(
            identifier: "stored-card-id",
            supportedShopperInteractions: [.shopperPresent],
            type: .scheme,
            name: "Visa"
        )

        sut.didRemove(paymentMethod: paymentMethod)

        #expect(listener.removedPaymentMethods.last?.identifier == paymentMethod.identifier)
    }

    @Test
    func didRequestPaymentOptions_forwardsRequestToListener() {
        let listener = StoredPaymentMethodManagementListenerMock()
        let sut = makeSUT(listener: listener)

        sut.didRequestPaymentOptions()

        #expect(listener.paymentOptionsRequestCount == 1)
    }

    @Test
    func didDismissFromNavigation_notifiesListenerOnlyOnce() {
        let listener = StoredPaymentMethodManagementListenerMock()
        let sut = makeSUT(listener: listener)

        sut.didDismissFromNavigation()
        sut.didDismissFromNavigation()

        #expect(listener.dismissalCount == 1)
    }

    private func makeSUT(
        rootViewController: UIViewController = UIViewController(),
        listener: StoredPaymentMethodManagementListener? = nil
    ) -> StoredPaymentMethodManagementRouter {
        StoredPaymentMethodManagementRouter(
            rootViewController: rootViewController,
            listener: listener
        )
    }
}
