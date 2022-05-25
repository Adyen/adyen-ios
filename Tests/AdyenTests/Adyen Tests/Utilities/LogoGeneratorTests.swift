//
//  LogoGenerator.swift
//  Adyen
//
//  Created by Vladimir Abramichev on 17/02/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class LogoURLProviderTests: XCTestCase {

    let scale = Int(UIScreen.main.scale)

    func testCardLogo() {
        let paymentMethod = try! Coder.decode(creditCardDictionary) as CardPaymentMethod
        let logo = LogoURLProvider.logoURL(
            withName: paymentMethod.displayInformation(using: nil).logoName,
            environment: Dummy.apiContext.environment
        )
        XCTAssertEqual(logo.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/small/card@\(scale)x.png")
    }

    func testSize() {
        let paymentMethod = try! Coder.decode(creditCardDictionary) as CardPaymentMethod
        let logo = LogoURLProvider.logoURL(
            withName: paymentMethod.displayInformation(using: nil).logoName,
            environment: Dummy.apiContext.environment,
            size: .large
        )
        XCTAssertEqual(logo.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/large/card@\(scale)x.png")

        let logo2 = LogoURLProvider.logoURL(
            withName: paymentMethod.displayInformation(using: nil).logoName,
            environment: Dummy.apiContext.environment,
            size: .medium
        )
        XCTAssertEqual(logo2.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/medium/card@\(scale)x.png")

        let logo3 = LogoURLProvider.logoURL(
            withName: paymentMethod.displayInformation(using: nil).logoName,
            environment: Dummy.apiContext.environment,
            size: .small
        )
        XCTAssertEqual(logo3.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/small/card@\(scale)x.png")
    }

    func testGiftCardLogo() {
        let paymentMethod = try! Coder.decode(giftCard) as GiftCardPaymentMethod
        let logo = LogoURLProvider.logoURL(
            withName: paymentMethod.displayInformation(using: nil).logoName,
            environment: Dummy.apiContext.environment
        )
        XCTAssertEqual(logo.absoluteString, "https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/small/genericgiftcard@\(scale)x.png")
    }

}
