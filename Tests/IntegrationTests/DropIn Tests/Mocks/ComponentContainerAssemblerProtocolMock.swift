//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn

@MainActor
final class ComponentContainerAssemblerProtocolMock: ComponentContainerAssemblerProtocol {

    // MARK: - resolveComponentContainerRouter

    var resolveComponentContainerRouterCallsCount = 0
    var resolveComponentContainerRouterCalled: Bool {
        resolveComponentContainerRouterCallsCount > 0
    }

    var resolveComponentContainerRouterReceivedArguments: (
        component: PaymentComponent,
        isDropInRoot: Bool,
        listener: ComponentContainerRouterListener
    )?
    var resolveComponentContainerRouterReturnValue: Router = RouterMock()
    var onResolveComponentContainerRouter: ((PaymentComponent, Bool, ComponentContainerRouterListener) -> Router)?

    func resolveComponentContainerRouter(
        for component: PaymentComponent,
        isDropInRoot: Bool,
        listener: ComponentContainerRouterListener
    ) -> Router {
        resolveComponentContainerRouterCallsCount += 1
        resolveComponentContainerRouterReceivedArguments = (component: component, isDropInRoot: isDropInRoot, listener: listener)
        return onResolveComponentContainerRouter?(component, isDropInRoot, listener) ?? resolveComponentContainerRouterReturnValue
    }
}
