//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCheckout
@testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class ComponentBuildPolicyTests: XCTestCase {

    func test_components_shouldFollowCheckoutConfigurationShowsSubmitButton() {
        let configuration = makeCheckoutConfiguration()

        XCTAssertTrue(ComponentBuildPolicy.components(configuration).showsSubmitButton)
        XCTAssertFalse(ComponentBuildPolicy.components(configuration.showsSubmitButton(false)).showsSubmitButton)
    }

    func test_dropIn_shouldAlwaysShowSubmitButton() {
        XCTAssertTrue(ComponentBuildPolicy.dropIn.showsSubmitButton)
    }

    func test_applying_shouldReturnConfigurationWithPolicySettings() {
        var blikConfiguration = BasicComponentConfiguration()
        blikConfiguration.showsSubmitButton = true
        let hidingPolicy = ComponentBuildPolicy.components(makeCheckoutConfiguration().showsSubmitButton(false))

        let hidden = blikConfiguration.applying(hidingPolicy)
        let shown = hidden.applying(.dropIn)

        XCTAssertTrue(blikConfiguration.showsSubmitButton)
        XCTAssertFalse(hidden.showsSubmitButton)
        XCTAssertTrue(shown.showsSubmitButton)
    }

    private func makeCheckoutConfiguration() -> CheckoutConfiguration {
        CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
    }
}
