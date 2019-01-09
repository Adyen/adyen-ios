//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenInternal
import XCTest

class PaymentInitiationResponseTests: XCTestCase {
    func testDecodingAuthorisedFromJSON() throws {
        let response = try Coder.decode(resourceNamed: "payment_initiation_authorised") as PaymentInitiationResponse
        guard case let .complete(paymentResult) = response else {
            fatalError("Unexpected response.")
        }
        
        XCTAssertEqual(paymentResult.status, .authorised)
        XCTAssertEqual(paymentResult.payload, "Ab02b4c0!BQABAgAPw+7E42geT5d6mGb7gZfDv3voyRTp5bltGDMC6xAInwbseEDDaZAku8J1cR+vjLpGHZjyqZy77ajoBHgTYEHwM/OJ/n8nMc2jXaIu7EirhVkMnyQGm+gizLJjx48QNTVPbJnmtxSiWOBk0shYAIBM1CoSxKcXyOliQuEGMnqHns8mlvvpIOaWGoDUbTQ7azJPHS84EsRIgsMor9Z670Adefw1zqyqHuO8RIalrYdzTsNeJq6yV6e9S1NMnNxz0DvlbL8Y3KfezoPjDswFInuBdm8btv6n8qwl8LgnyrCUdZQbnC2RHsyRtY0EaxvV+724fcMQ4E0w/u2quWooL6ltpebuJrPXikB9n3Dh91FaRg7mN4OPZwZZdeGjw7pGArXTN+l9ZbFzpZsjOqBX71qutMeMi+UEEBbCIJ6kuCdotXwX068NL/VxMj1cJtrsUby/bFa4mhhj1fA5QPkX92XCVK9bJMuQFM9xscOuVMCFypfJstWTTGfA8g4vrLX9+pSpiL0Oh7eYAOiGAtyqOqLetnk1uZJzdyrQowr7VkgTxTpvJ7VfsxB1tbsi+FEoE/6/fwUwvjek6WCHYI43wowdUEqAzq2RwpLBI54rDvdfij44TQkX82UQJrR/q955ng7GXGS7XJ2/f4ODOKX2vzgfa6V8kYQ6C8ZbgthcorPswBBAJGKnOwYUvH+7OKdzfiFXAEp7ImtleSI6IkFGMEFBQTEwM0NBNTM3RUFFRDg3QzI0REQ1MzkwOUI4MEE3OEE5MjNFMzgyM0Q2OERBQ0M5NEI5RkY4MzA1REMifc/SosVRHwKTQhfzqf0/gX3mnOYnslZmbCSLXVHY6addjlJzPtWSFCQg4Y9agKoN8f7K6JFZfAgAOHAlIhSKhpsY/JI0JJGKNMoG1dC8g5gNS4yf/VbrYKflrtsagr8ZRWsZjnPsLBa3YN4D0R7ip1ivDvEjAeX0nUIw13gZq/9VyVIY3AtYfMR0G1IRLIxLKA==")
    }
    
    func testDecodingRedirectFromJSON() throws {
        let response = try Coder.decode(resourceNamed: "payment_initiation_redirect") as PaymentInitiationResponse
        guard case let .redirect(redirect) = response else {
            fatalError("Unexpected response.")
        }
        
        XCTAssertEqual(redirect.url.absoluteString, "https://test.adyen.com/hpp/ideal/IssuerPage?ret=ui-host%3A%2F%2F%3FpspEchoData%3D8515250906720597%253A17408%253A1153%253A536%253AbHih4%252Bsqhme0epdsFvmbszNPMio%253D%26trxid%3D115321_JvdF9lsni%26ec%3D8515250906720597&amount=174.08&currency=EUR")
        XCTAssertTrue(redirect.shouldSubmitReturnURLQuery)
    }
    
    func testDecodingErrorFromJSON() throws {
        let response = try Coder.decode(resourceNamed: "payment_initiation_error") as PaymentInitiationResponse
        guard case let .error(error) = response else {
            fatalError("Unexpected response.")
        }
        
        XCTAssertEqual(error.code, "PI002")
        XCTAssertEqual(error.message, "Error message")
    }
    
}
