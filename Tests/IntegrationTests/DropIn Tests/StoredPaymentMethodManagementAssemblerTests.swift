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

    @Test
    func resolveRouter_disablesNavigationWhileRemovalIsInProgressAndRestoresOriginalState() async throws {
        var removalContinuation: CheckedContinuation<Void, Never>?
        let paymentMethod = storedPaymentMethod()
        let listener = StoredPaymentMethodManagementListenerMock()
        let router = try #require(
            StoredPaymentMethodManagementAssembler(
                localizationParameters: nil,
                logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
                theme: .default
            ).resolveStoredPaymentMethodManagementRouter(
                paymentMethods: [paymentMethod],
                capability: StoredPaymentMethodManagementCapability { _ in
                    await withCheckedContinuation { continuation in
                        removalContinuation = continuation
                    }
                },
                listener: listener
            ) as? StoredPaymentMethodManagementRouter
        )
        let hostingController = try #require(router.rootViewController as? StoredPaymentMethodManagementHostingController)
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.pushViewController(hostingController, animated: false)
        let originalTintColor = UIColor.systemPurple
        navigationController.navigationBar.isUserInteractionEnabled = true
        navigationController.navigationBar.tintColor = originalTintColor
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        hostingController.viewWillAppear(false)
        let item = try #require(hostingController.viewModel.sections.first?.items.first)

        hostingController.viewModel.onRemoveButtonTap(item)
        let removal = Task { await hostingController.viewModel.onRemoveConfirmButtonTap(item) }
        await Task.yield()

        #expect(!navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.navigationBar.tintColor != originalTintColor)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)

        hostingController.viewWillDisappear(false)

        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.navigationBar.tintColor == originalTintColor)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)

        hostingController.viewWillAppear(false)
        #expect(!navigationController.navigationBar.isUserInteractionEnabled)

        let continuation = try #require(removalContinuation)
        continuation.resume()
        await removal.value

        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.navigationBar.tintColor == originalTintColor)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
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
