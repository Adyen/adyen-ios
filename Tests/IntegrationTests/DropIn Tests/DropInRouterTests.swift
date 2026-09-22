//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct DropInRouterTests {

    // MARK: - Root ViewController Tests

    @Test
    func rootViewController_givenPaymentMethodListRoot_shouldRetainPaymentMethodListRouter() {
        // Given
        let paymentMethodListRouter = RouterMock()
        let sut = makeSUT(paymentMethodListRouter: paymentMethodListRouter)

        // When
        let rootViewController = sut.rootViewController

        // Then
        #expect(rootViewController === paymentMethodListRouter.rootViewController)
        #expect(sut.childRouter === paymentMethodListRouter)
    }

    // MARK: - PaymentMethodListRouterListener Tests

    @Test
    func didDismissPaymentMethodList_shouldDismissDropIn() {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let paymentMethodListRouter = RouterMock()
        paymentMethodListRouter.rootViewController = viewControllerSpy
        let sut = makeSUT(paymentMethodListRouter: paymentMethodListRouter)
        _ = sut.rootViewController

        // When
        sut.didDismissPaymentMethodList(completion: nil)

        // Then
        #expect(viewControllerSpy.dismissCallsCount == 1)
    }

    @Test
    func didDismissPaymentMethodList_shouldReleaseChildRouterAndCallCompletion() throws {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let paymentMethodListRouter = RouterMock()
        paymentMethodListRouter.rootViewController = viewControllerSpy
        let sut = makeSUT(paymentMethodListRouter: paymentMethodListRouter)
        _ = sut.rootViewController
        try #require(sut.childRouter != nil)
        var completionCalled = false

        // When
        sut.didDismissPaymentMethodList { completionCalled = true }

        // Then
        #expect(sut.childRouter == nil)
        #expect(completionCalled)
    }

    // MARK: - Helpers

    private func makeSUT(
        paymentMethodListRouter: RouterMock
    ) -> DropInRouter {
        let paymentMethodListAssembler = PaymentMethodListAssemblerProtocolMock()
        paymentMethodListAssembler.resolvePaymentMethodListRouterDelegateReturnValue = paymentMethodListRouter

        return DropInRouter(
            viewModel: DropInViewModelStub(),
            preselectedPaymentMethodAssembler: PreselectedPaymentMethodAssemblerProtocolMock(),
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock()
        )
    }
}

@MainActor
private struct DropInViewModelStub: DropInViewModelProtocol {
    let root: DropInRoot = .paymentMethodList
    let title: String = "Test Title"
}
