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
struct StoredPaymentMethodManagementAssemblerTests {

    @Test
    func resolveRouter_wiresNavigationDismissalToListener() throws {
        let listener = StoredPaymentMethodManagementListenerMock()
        let router = try #require(
            StoredPaymentMethodManagementAssembler(
                localizationParameters: nil,
                logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
                theme: .default
            ).resolveStoredPaymentMethodManagementRouter(
                paymentMethods: [storedPaymentMethod()],
                capability: StoredPaymentMethodManagementCapability { _ in },
                listener: listener
            ) as? StoredPaymentMethodManagementRouter
        )
        let hostingController = try #require(router.rootViewController as? StoredPaymentMethodManagementHostingController)

        hostingController.onDismissFromNavigation?()
        hostingController.onDismissFromNavigation?()

        #expect(listener.dismissalCount == 1)
    }

    @Test
    func resolveRouter_configuresLargeNavigationTitle() throws {
        let listener = StoredPaymentMethodManagementListenerMock()
        let router = try #require(
            StoredPaymentMethodManagementAssembler(
                localizationParameters: nil,
                logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
                theme: .default
            ).resolveStoredPaymentMethodManagementRouter(
                paymentMethods: [storedPaymentMethod()],
                capability: StoredPaymentMethodManagementCapability { _ in },
                listener: listener
            ) as? StoredPaymentMethodManagementRouter
        )
        let hostingController = try #require(router.rootViewController as? StoredPaymentMethodManagementHostingController)
        let navigationController = UINavigationController(rootViewController: hostingController)

        hostingController.loadViewIfNeeded()

        #expect(hostingController.navigationItem.title == hostingController.viewModel.title)
        #expect(hostingController.navigationItem.largeTitleDisplayMode == .always)
        #expect(navigationController.navigationBar.prefersLargeTitles)
    }

    @Test
    func resolveRouter_createsHostingControllerAndWiresViewModelRouter() throws {
        let listener = StoredPaymentMethodManagementListenerMock()
        let sut = StoredPaymentMethodManagementAssembler(
            localizationParameters: nil,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            theme: .default
        )

        let router = try #require(
            sut.resolveStoredPaymentMethodManagementRouter(
                paymentMethods: [storedPaymentMethod()],
                capability: StoredPaymentMethodManagementCapability { _ in },
                listener: listener
            ) as? StoredPaymentMethodManagementRouter
        )
        let hostingController = try #require(router.rootViewController as? StoredPaymentMethodManagementHostingController)

        #expect(hostingController.viewModel.router === router)
    }

    private func storedPaymentMethod() -> StoredPaymentMethodMock {
        StoredPaymentMethodMock(
            identifier: "stored-payment-method-id",
            supportedShopperInteractions: [.shopperPresent],
            type: .scheme,
            name: "Visa"
        )
    }
}
