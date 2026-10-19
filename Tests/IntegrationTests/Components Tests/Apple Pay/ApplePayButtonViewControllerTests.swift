//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import PassKit
import XCTest

@MainActor
final class ApplePayButtonViewControllerTests: XCTestCase {

    func test_viewDidLoad_givenShowsSubmitButton_shouldAddPaymentButton() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.paymentButton.isDescendant(of: sut.view))
        XCTAssertEqual(sut.view.subviews, [sut.paymentButton])
    }

    func test_viewDidLoad_givenShowsSubmitButtonFalse_shouldBeEmpty() {
        let sut = makeSUT(showsSubmitButton: false)

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.view.subviews.isEmpty)
    }

    func test_paymentButton_givenNoAppearanceCornerRadius_shouldKeepSystemCornerRadius() {
        let systemButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .automatic)
        let sut = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.paymentButton.cornerRadius, systemButton.cornerRadius)
    }

    func test_paymentButton_givenAppearanceCornerRadius_shouldUseAppearanceCornerRadius() {
        let sut = makeSUT(appearance: ApplePayButtonAppearance(cornerRadius: 21))

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.paymentButton.cornerRadius, 21)
    }

    func test_paymentButtonTap_shouldCallOnSubmit() {
        let sut = makeSUT()
        var submitCount = 0
        sut.onSubmit = { submitCount += 1 }
        sut.loadViewIfNeeded()

        sut.paymentButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(submitCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        appearance: ApplePayButtonAppearance = ApplePayButtonAppearance(),
        showsSubmitButton: Bool = true
    ) -> ApplePayButtonViewController {
        ApplePayButtonViewController(
            appearance: appearance,
            showsSubmitButton: showsSubmitButton
        )
    }
}
