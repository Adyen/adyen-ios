//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

#if canImport(AdyenAuthentication)
    @_spi(AdyenInternal) @testable import Adyen
    import Adyen3DS2
    @_spi(AdyenInternal) @testable import AdyenActions
    import AdyenAuthentication
    import Foundation
    import UIKit

    class ThreeDS2PlusDACoreActionHandlerTests: XCTestCase {

        var authenticationRequestParameters: AnyAuthenticationRequestParameters!

        var fingerprintAction: ThreeDS2FingerprintAction!

        var challengeAction: ThreeDS2ChallengeAction!
        
        static let appleTeamIdentifier = "B2NYSS5932"
        
        static var delegatedAuthenticationConfigurations: ThreeDS2Component.Configuration.DelegatedAuthentication {
            .init(localizedRegistrationReason: "Authenticate your card!",
                  localizedAuthenticationReason: "Register this device!",
                  appleTeamIdentifier: appleTeamIdentifier)
            
        }
    
        lazy var analyticsEvent: Analytics.Event = .init(component: "Dropin",
                                                         flavor: .dropin,
                                                         context: Dummy.apiContext)
        
        override func setUp() {
            super.setUp()

            authenticationRequestParameters = AuthenticationRequestParametersMock(deviceInformation: "device_info",
                                                                                  sdkApplicationIdentifier: "sdkApplicationIdentifier",
                                                                                  sdkTransactionIdentifier: "sdkTransactionIdentifier",
                                                                                  sdkReferenceNumber: "sdkReferenceNumber",
                                                                                  sdkEphemeralPublicKey: sdkPublicKey,
                                                                                  messageVersion: "messageVersion")

            fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: fingerprintToken,
                                                          authorisationToken: "AuthToken",
                                                          paymentData: "paymentData")

            challengeAction = ThreeDS2ChallengeAction(challengeToken: challengeToken, authorisationToken: "authToken", paymentData: "paymentData")
        }

        func testSettingThreeDSRequestorAppURL() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      appearanceConfiguration: ADYAppearanceConfiguration(),
                                                      delegatedAuthenticationConfiguration: Self.delegatedAuthenticationConfigurations)
            sut.threeDSRequestorAppURL = URL(string: "https://google.com")
            XCTAssertEqual(sut.threeDSRequestorAppURL, URL(string: "https://google.com"))
        }
        
        func testWrappedComponent() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      appearanceConfiguration: ADYAppearanceConfiguration(),
                                                      delegatedAuthenticationConfiguration: Self.delegatedAuthenticationConfigurations)
            XCTAssertEqual(sut.context.apiContext.clientKey, Dummy.apiContext.clientKey)
        
            XCTAssertEqual(sut.context.apiContext.environment.baseURL, Dummy.apiContext.environment.baseURL)

            sut._isDropIn = false
            XCTAssertEqual(sut._isDropIn, false)

            sut._isDropIn = true
            XCTAssertEqual(sut._isDropIn, true)
        }

        func testFingerprintFlowSuccess() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let service = AnyADYServiceMock()
            service.authenticationRequestParameters = authenticationRequestParameters
        
            let expectedFingerprint = try ThreeDS2Component.Fingerprint(
                authenticationRequestParameters: authenticationRequestParameters,
                delegatedAuthenticationSDKOutput: nil
            )
        
            let authenticationServiceMock = AuthenticationServiceMock()
        
            let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      service: service,
                                                      delegatedAuthenticationService: authenticationServiceMock)
            sut.handle(fingerprintAction, event: analyticsEvent) { fingerprintResult in
                switch fingerprintResult {
                case let .success(fingerprintString):
                    let fingerprint: ThreeDS2Component.Fingerprint = try! AdyenCoder.decodeBase64(fingerprintString)
                    XCTAssertEqual(fingerprint, expectedFingerprint)
                case .failure:
                    XCTFail()
                }
                resultExpectation.fulfill()
            }
        
            waitForExpectations(timeout: 2, handler: nil)
        }

        func testInvalidFingerprintToken() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let service = AnyADYServiceMock()
            service.authenticationRequestParameters = authenticationRequestParameters
        
            let authenticationServiceMock = AuthenticationServiceMock()

            let fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: "Invalid-token",
                                                              authorisationToken: "AuthToken",
                                                              paymentData: "paymentData")

            let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      service: service,
                                                      delegatedAuthenticationService: authenticationServiceMock)
            sut.handle(fingerprintAction,
                       event: analyticsEvent) { result in
                switch result {
                case .success:
                    XCTFail()
                case let .failure(error):
                    let decodingError = error as? DecodingError
                    switch decodingError {
                    case .dataCorrupted?: ()
                    default:
                        XCTFail()
                    }
                }
                resultExpectation.fulfill()
            }

            waitForExpectations(timeout: 2, handler: nil)
        }

        func testChallengeFlowSuccess() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let service = AnyADYServiceMock()
            service.authenticationRequestParameters = authenticationRequestParameters

            let transaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
            transaction.onPerformChallenge = { params, completion in
                XCTAssertEqual(params.threeDSRequestorAppURL, URL(string: "https://google.com"))
                completion(AnyChallengeResultMock(sdkTransactionIdentifier: "sdkTxId", transactionStatus: "Y"), nil)
            }
            service.mockedTransaction = transaction
        
            let authenticationServiceMock = AuthenticationServiceMock()
        
            authenticationServiceMock.onRegister = { _ in
                self.expectedSDKRegistrationOutput
            }
        
            let expectedResult = try ThreeDSResult(
                from: AnyChallengeResultMock(
                    sdkTransactionIdentifier: "sdkTransactionIdentifier",
                    transactionStatus: "Y"
                ),
                delegatedAuthenticationSDKOutput: expectedSDKRegistrationOutput,
                authorizationToken: "authToken",
                threeDS2SDKError: nil
            )

            let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      service: service,
                                                      delegatedAuthenticationService: authenticationServiceMock)
            sut.threeDSRequestorAppURL = URL(string: "https://google.com")
            sut.transaction = transaction
            sut.delegatedAuthenticationState.isDeviceRegistrationFlow = true
            sut.handle(challengeAction, event: analyticsEvent) { challengeResult in
                switch challengeResult {
                case let .success(result):
                    do {
                        let json = try XCTUnwrap(JSONSerialization.jsonObject(
                            with: result.payload.dataFromBase64URL(),
                            options: []
                        ) as? [String: Any]
                        )
                        
                        let expectedJson = try XCTUnwrap(JSONSerialization.jsonObject(
                            with: expectedResult.payload.dataFromBase64URL(),
                            options: []
                        ) as? [String: Any]
                        )

                        XCTAssertEqual(json["transStatus"] as? String, expectedJson["transStatus"] as? String)
                        XCTAssertEqual(json["authorisationToken"] as? String, expectedJson["authorisationToken"] as? String)
                        
                        let delegatedAuthenticationSDKOutput = try XCTUnwrap(JSONSerialization.jsonObject(
                            with: XCTUnwrap(json["delegatedAuthenticationSDKOutput"] as? String).dataFromBase64URL(),
                            options: []
                        ) as? [String: Any]
                        )

                        let expectedDelegatedAuthenticationSDKOutput = try XCTUnwrap(JSONSerialization.jsonObject(
                            with: XCTUnwrap(expectedJson["delegatedAuthenticationSDKOutput"] as? String).dataFromBase64URL(),
                            options: []
                        ) as? [String: Any]
                        )

                        XCTAssertEqual(
                            NSDictionary(dictionary: delegatedAuthenticationSDKOutput),
                            NSDictionary(dictionary: expectedDelegatedAuthenticationSDKOutput)
                        )
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                case .failure:
                    XCTFail()
                }
                resultExpectation.fulfill()
            }

            waitForExpectations(timeout: 2, handler: nil)
        }
    
        func testChallengeFlowFailure() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let service = AnyADYServiceMock()
            service.authenticationRequestParameters = authenticationRequestParameters
            let mockedTransaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
            service.mockedTransaction = mockedTransaction

            mockedTransaction.onPerformChallenge = { parameters, completion in
                completion(nil, Dummy.error)
            }

            let authenticationServiceMock = AuthenticationServiceMock()
        
            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      service: service,
                                                      delegatedAuthenticationService: authenticationServiceMock)
            sut.transaction = mockedTransaction

            let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")

            sut.handle(challengeAction, event: analyticsEvent) { result in
                switch result {
                case let .success(result):
                    
                    struct Payload: Codable {
                        let threeDS2SDKError: String?
                    }

                    let payload: Payload? = try? AdyenCoder.decodeBase64(result.payload)
                    XCTAssertNotNil(payload?.threeDS2SDKError)
                case .failure:
                    XCTFail()
                }
                resultExpectation.fulfill()
            }

            waitForExpectations(timeout: 2, handler: nil)
        }

        func testChallengeFlowMissingTransaction() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let service = AnyADYServiceMock()
        
            let authenticationServiceMock = AuthenticationServiceMock()

            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      service: service,
                                                      delegatedAuthenticationService: authenticationServiceMock)

            let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
            sut.handle(challengeAction, event: analyticsEvent) { result in
                switch result {
                case .success:
                    XCTFail()
                case let .failure(error):
                    let componentError = error as? ThreeDS2Component.Error
                    switch componentError {
                    case .missingTransaction?: ()
                    default:
                        XCTFail()
                    }
                }
                resultExpectation.fulfill()
            }

            waitForExpectations(timeout: 2, handler: nil)
        }

        func testInvalidChallengeToken() throws {
            guard #available(iOS 14.0, *) else {
                // XCTestCase does not respect @available so we have skip all tests here
                throw XCTSkip("Unsupported iOS version")
            }
            
            let service = AnyADYServiceMock()
            service.authenticationRequestParameters = authenticationRequestParameters
            let mockedTransaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
            service.mockedTransaction = mockedTransaction

            mockedTransaction.onPerformChallenge = { parameters, completion in
                XCTFail()
            }

            let authenticationServiceMock = AuthenticationServiceMock()

            let sut = ThreeDS2PlusDACoreActionHandler(context: Dummy.context,
                                                      service: service,
                                                      delegatedAuthenticationService: authenticationServiceMock)
            sut.transaction = mockedTransaction

            let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")

            let challengeAction = ThreeDS2ChallengeAction(challengeToken: "Invalid-token", authorisationToken: "AuthToken", paymentData: "paymentData")
            sut.handle(challengeAction, event: analyticsEvent) { result in
                switch result {
                case .success:
                    XCTFail()
                case let .failure(error):
                    let decodingError = error as? DecodingError
                    switch decodingError {
                    case .dataCorrupted?: ()
                    default:
                        XCTFail()
                    }
                }
                resultExpectation.fulfill()
            }

            waitForExpectations(timeout: 2, handler: nil)
        }

    }

#endif
