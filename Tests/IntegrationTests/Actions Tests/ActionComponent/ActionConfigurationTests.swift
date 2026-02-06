//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

final class ActionConfigurationTests: XCTestCase {
    
    // MARK: - ThreeDS2ActionConfiguration Tests
    
    func testThreeDS2ActionConfigurationDefaultInitialization() {
        let config = ThreeDS2ActionConfiguration()
        
        XCTAssertNil(config.requestorAppURL)
        XCTAssertNil(config.delegatedAuthentication)
    }
    
    func testThreeDS2ActionConfigurationRequestorAppURLBuilder() throws {
        let expectedURL = try XCTUnwrap(URL(string: "https://example.com"))
        
        let config = ThreeDS2ActionConfiguration()
            .requestorAppURL(expectedURL)
        
        XCTAssertEqual(config.requestorAppURL, expectedURL)
    }
    
    func testThreeDS2ActionConfigurationDelegatedAuthenticationBuilder() {
        let delegatedAuth = ThreeDS2ActionConfiguration.DelegatedAuthentication(
            relyingPartyIdentifier: "example.com"
        )
        
        let config = ThreeDS2ActionConfiguration()
            .delegatedAuthentication(delegatedAuth)
        
        XCTAssertNotNil(config.delegatedAuthentication)
        XCTAssertEqual(config.delegatedAuthentication?.relyingPartyIdentifier, "example.com")
    }
    
    func testThreeDS2ActionConfigurationChainedBuilders() throws {
        let expectedURL = try XCTUnwrap(URL(string: "https://example.com"))
        let delegatedAuth = ThreeDS2ActionConfiguration.DelegatedAuthentication(
            relyingPartyIdentifier: "example.com"
        )
        
        let config = ThreeDS2ActionConfiguration()
            .requestorAppURL(expectedURL)
            .delegatedAuthentication(delegatedAuth)
        
        XCTAssertEqual(config.requestorAppURL, expectedURL)
        XCTAssertNotNil(config.delegatedAuthentication)
        XCTAssertEqual(config.delegatedAuthentication?.relyingPartyIdentifier, "example.com")
    }
    
    func testDelegatedAuthenticationInitialization() {
        let delegatedAuth = ThreeDS2ActionConfiguration.DelegatedAuthentication(
            relyingPartyIdentifier: "test.example.com"
        )
        
        XCTAssertEqual(delegatedAuth.relyingPartyIdentifier, "test.example.com")
    }
    
    // MARK: - TwintActionConfiguration Tests
    
    func testTwintActionConfigurationInitialization() {
        let config = TwintActionConfiguration(callbackAppScheme: "my-app")
        
        XCTAssertEqual(config.callbackAppScheme, "my-app")
        XCTAssertEqual(config.maxIssuerNumber, .max)
    }
    
    func testTwintActionConfigurationMaxIssuerNumberBuilder() {
        let config = TwintActionConfiguration(callbackAppScheme: "my-app")
            .maxIssuerNumber(39)
        
        XCTAssertEqual(config.callbackAppScheme, "my-app")
        XCTAssertEqual(config.maxIssuerNumber, 39)
    }
    
    func testTwintActionConfigurationValidSchemes() {
        let validSchemes = ["scheme", "my-app", "myApp123"]
        
        for scheme in validSchemes {
            AdyenAssertion.listener = { _ in
                XCTFail("No assertion should have been raised for scheme: \(scheme)")
            }
            
            let config = TwintActionConfiguration(callbackAppScheme: scheme)
            XCTAssertEqual(config.callbackAppScheme, scheme)
        }
        
        AdyenAssertion.listener = nil
    }
    
    func testTwintActionConfigurationInvalidSchemes() {
        let invalidSchemes = [
            "scheme:",
            "scheme://",
            "scheme://host"
        ]
        
        for scheme in invalidSchemes {
            let assertionExpectation = expectation(description: "Assertion for \(scheme)")
            
            AdyenAssertion.listener = { message in
                XCTAssertEqual(message, "Format of provided callbackAppScheme '\(scheme)' is incorrect.")
                assertionExpectation.fulfill()
            }
            
            _ = TwintActionConfiguration(callbackAppScheme: scheme)
            
            wait(for: [assertionExpectation], timeout: 0.1)
        }
        
        AdyenAssertion.listener = nil
    }
}
