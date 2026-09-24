//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import SafariServices
import Testing
import UIKit

@MainActor
struct PaymentActionAssemblerTests {

    // MARK: - Tests

    @Test("Action components that do not manage their own navigation are hosted in a container that adds a done button.")
    func resolvePaymentActionRouter_givenAPlainViewController_shouldHostItInAPaymentActionViewController() throws {
        // Given
        let sut = PaymentActionAssembler()
        let actionViewController = UIViewController()

        // When
        let router = sut.resolvePaymentActionRouter(
            for: actionViewController,
            listener: PaymentActionRouterListenerMock(),
            onCancel: {}
        )

        // Then
        let hostViewController = try #require(router.rootViewController as? PaymentActionViewController)
        #expect(hostViewController.actionViewController === actionViewController)
    }

    @Test("A web view is used as is, to avoid embedding it inside another view.")
    func resolvePaymentActionRouter_givenASafariViewController_shouldUseItAsTheRoot() throws {
        // Given
        let sut = PaymentActionAssembler()
        let actionViewController = try SFSafariViewController(url: #require(URL(string: "https://adyen.com")))

        // When
        let router = sut.resolvePaymentActionRouter(
            for: actionViewController,
            listener: PaymentActionRouterListenerMock(),
            onCancel: {}
        )

        // Then
        #expect(router.rootViewController === actionViewController)
    }

    @Test("Action components that manage their own navigation are used as is.")
    func resolvePaymentActionRouter_givenANavigationController_shouldUseItAsTheRoot() {
        // Given
        let sut = PaymentActionAssembler()
        let actionViewController = UINavigationController(rootViewController: UIViewController())

        // When
        let router = sut.resolvePaymentActionRouter(
            for: actionViewController,
            listener: PaymentActionRouterListenerMock(),
            onCancel: {}
        )

        // Then
        #expect(router.rootViewController === actionViewController)
    }

    @Test("Dismissing the hosted action routes through the view model to the router, and notifies the listener.")
    func resolvePaymentActionRouter_whenTheHostedActionIsDismissed_shouldNotifyTheListenerAndCallOnCancel() throws {
        // Given
        let sut = PaymentActionAssembler()
        let listenerMock = PaymentActionRouterListenerMock()
        var onCancelCallsCount = 0

        var receivedCompletion: (() -> Void)?
        listenerMock.didDismissPaymentActionCompletionClosure = { receivedCompletion = $0 }

        let router = sut.resolvePaymentActionRouter(
            for: UIViewController(),
            listener: listenerMock,
            onCancel: { onCancelCallsCount += 1 }
        )

        let hostViewController = try #require(router.rootViewController as? PaymentActionViewController)
        hostViewController.loadViewIfNeeded()

        // When
        let doneButton = try #require(hostViewController.navigationItem.rightBarButtonItem)
        _ = try hostViewController.perform(#require(doneButton.action), with: doneButton)

        // Then
        // The merchant is only informed once the drop in has been dismissed.
        #expect(listenerMock.didDismissPaymentActionCompletionCallsCount == 1)
        #expect(onCancelCallsCount == 0)

        receivedCompletion?()
        #expect(onCancelCallsCount == 1)
    }
}
