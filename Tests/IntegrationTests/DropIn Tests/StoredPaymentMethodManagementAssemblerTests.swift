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
    func resolveRouter_usesStandardNavigationBar() throws {
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

        #expect(hostingController.navigationItem.title == nil)
        #expect(hostingController.navigationItem.largeTitleDisplayMode == .never)
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
