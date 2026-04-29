//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest
@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenUI

@MainActor
class AuthenticationComponentTests: XCTestCase {

    /// Verifies that a redirect action during fingerprint flow completes successfully with RedirectDetails.
    func testFullFlowRedirectSuccess() throws {

        let mockedAction = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "data")

        let mockedDetails = try RedirectDetails(returnURL: Dummy.returnUrl)
        let mockedData = ActionComponentData(details: mockedDetails, paymentData: "data")

        let threeDSActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDSActionHandler.mockedFingerprintResult = try .success(.action(.redirect(RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "data"))))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { [weak redirectComponent] action in
            guard let redirectComponent else { return }

            XCTAssertEqual(action, mockedAction)

            redirectComponent.delegate?.didProvide(mockedData, from: redirectComponent)
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDSActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(data.paymentData, mockedData.paymentData)
            guard let details = data.details as? RedirectDetails else {
                XCTFail("Expected RedirectDetails but got \(type(of: data.details))")
                return
            }
            XCTAssertEqual(details.redirectResult, "some")

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 10, handler: nil)
    }

    /// Verifies that a redirect failure propagates the error correctly.
    func testFullFlowRedirectFailure() throws {
        let mockedAction = try RedirectAction(url: XCTUnwrap(URL(string: "https://www.adyen.com")), paymentData: "data")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.redirect(mockedAction)))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { [weak redirectComponent] action in
            guard let redirectComponent else { return }

            XCTAssertEqual(action, mockedAction)

            redirectComponent.delegate?.didFail(with: Dummy.error, from: redirectComponent)

        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.error)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    /// Verifies that a challenge action during fingerprint flow completes successfully with ThreeDSResult.
    func testFullFlowChallengeSuccess() {

        let mockedAction = ThreeDS2ChallengeAction(
            challengeToken: "token",
            authorisationToken: "AuthToken",
            paymentData: "data"
        )

        let mockedDetails = ThreeDSResult(payload: "payload")

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.threeDS2(.challenge(mockedAction))))
        threeDS2ActionHandler.mockedChallengeResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNil(data.paymentData)
            XCTAssertNotNil(data.details as? ThreeDSResult)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    /// Verifies that an unexpected action type results in the appropriate error.
    func testFullFlowUnexpectedAction() {

        let mockedAwaitAction = AwaitAction(
            paymentData: "data",
            paymentMethodType: .blik
        )

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.await(mockedAwaitAction)))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        delegate.onDidProvide = { data, component in
            XCTFail("didProvide should never be called")
        }
        let delegateExpectation = expectation(description: "Expect delegate didFail(with:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)

            switch error as? AuthenticationComponent.Error {
            case .unexpectedAction:
                break
            default:
                XCTFail()
            }
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    /// Verifies that a challenge failure propagates the error correctly.
    func testFullFlowChallengeFailure() {

        let mockedAction = ThreeDS2ChallengeAction(
            challengeToken: "token",
            authorisationToken: "AuthToken",
            paymentData: "data"
        )

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .success(.action(.threeDS2(.challenge(mockedAction))))
        threeDS2ActionHandler.mockedChallengeResult = .failure(Dummy.error)

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.error)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    /// Verifies that a fingerprint failure propagates the error correctly.
    func testFullFlowFingerprintFailure() {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()
        threeDS2ActionHandler.mockedFingerprintResult = .failure(Dummy.error)

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidFail = { error, component in
            XCTAssertTrue(component === sut)
            XCTAssertEqual(error as? Dummy, Dummy.error)

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    /// Verifies that a successful fingerprint flow returns the expected ThreeDSResult.
    func testFingerprintSuccess() {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedDetails = ThreeDSResult(payload: "payload")
        threeDS2ActionHandler.mockedFingerprintResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = AuthenticationComponent(
            context: Dummy.context(analyticsProvider: analyticsProviderMock),
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            guard let threeDSResult = data.details as? ThreeDSResult else {
                XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                return
            }
            XCTAssertEqual(threeDSResult.payload, "payload")

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    /// Verifies that setting requestorAppURL propagates to the compact flow handler.
    func testSettingRequestorAppURL() {
        let sut = AuthenticationComponent(context: Dummy.context)
        sut.configuration.requestorAppURL = URL(string: "https://google.com")
        XCTAssertEqual(sut.threeDS2CompactFlowHandler.threeDSRequestorAppURL, URL(string: "https://google.com"))
    }
    
    /// Verifies that requestorAppURL can be set via configuration initializer.
    func testSettingRequestorAppURLWithInitializer() throws {
        let configuration = try AuthenticationConfiguration()
            .requestorAppURL(XCTUnwrap(URL(string: "https://google.com")))
        let sut = AuthenticationComponent(
            context: Dummy.context,
            configuration: configuration
        )
        XCTAssertEqual(sut.threeDS2CompactFlowHandler.threeDSRequestorAppURL, URL(string: "https://google.com"))
    }
    
    /// Verifies that requestorAppURL works with injected handlers.
    func testSettingRequestorAppURLWithInitializerAndInjectedHandlers() throws {
        let threeDS2CompactFlowHandler = AnyThreeDS2ActionHandlerMock()
        let redirectComponent = AnyRedirectComponentMock()
        let configuration = try AuthenticationConfiguration()
            .requestorAppURL(XCTUnwrap(URL(string: "https://google.com")))
        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2CompactFlowHandler,
            redirectComponent: redirectComponent,
            configuration: configuration
        )
        XCTAssertEqual(sut.threeDS2CompactFlowHandler.threeDSRequestorAppURL, URL(string: "https://google.com"))
    }

    /// Verifies that a successful challenge returns the expected ThreeDSResult with correct payload.
    func testChallengeSuccess() throws {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedResult = try ThreeDSResult(authenticated: true, authorizationToken: "AuthToken")
        threeDS2ActionHandler.mockedChallengeResult = .success(.details(mockedResult))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertNil(data.paymentData)

            guard let threeDSResult = data.details as? ThreeDSResult else {
                XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                return
            }
            guard let payloadData = Data(base64Encoded: threeDSResult.payload),
                  let json = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: String] else {
                XCTFail("Failed to decode payload")
                return
            }
            XCTAssertEqual(json["transStatus"], "Y")
            XCTAssertEqual(json["authorisationToken"], "AuthToken")

            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.challenge(ThreeDS2ChallengeAction(challengeToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    /// Verifies that a frictionless flow completes successfully with the expected ThreeDSResult.
    func testFullFlowFrictionless() {

        let threeDS2ActionHandler = AnyThreeDS2ActionHandlerMock()

        let mockedDetails = ThreeDSResult(payload: "payload")
        threeDS2ActionHandler.mockedFingerprintResult = .success(.details(mockedDetails))

        let redirectComponent = AnyRedirectComponentMock()
        redirectComponent.onHandle = { action in
            XCTFail("RedirectComponent should never be invoked.")
        }

        let sut = AuthenticationComponent(
            context: Dummy.context,
            threeDS2CompactFlowHandler: threeDS2ActionHandler,
            redirectComponent: redirectComponent
        )
        redirectComponent.delegate = sut

        let delegate = ActionComponentDelegateMock()
        let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
        delegate.onDidProvide = { data, component in
            XCTAssertTrue(component === sut)

            guard let details = data.details as? ThreeDSResult else {
                XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                return
            }
            XCTAssertEqual(details, ThreeDSResult(payload: "payload"))
            delegateExpectation.fulfill()
        }
        sut.delegate = delegate

        sut.handle(ThreeDS2Action.fingerprint(ThreeDS2FingerprintAction(fingerprintToken: "token", authorisationToken: "AuthToken", paymentData: "data")))

        waitForExpectations(timeout: 2, handler: nil)
    }

    #if canImport(AdyenAuthentication)
        /// Verifies that the delegated authentication approval flow succeeds when user approves.
        func testDelegatedAuthenticationApprovalFlow() {
            enum TestData {
                static let fingerprintToken = "eyJkZWxlZ2F0ZWRBdXRoZW50aWNhdGlvblNES0lucHV0IjoiIyNTb21lZGVsZWdhdGVkQXV0aGVudGljYXRpb25TREtJbnB1dCMjIiwiZGlyZWN0b3J5U2VydmVySWQiOiJGMDEzMzcxMzM3IiwiZGlyZWN0b3J5U2VydmVyUHVibGljS2V5IjoiI0RpcmVjdG9yeVNlcnZlclB1YmxpY0tleSMiLCJkaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIjoiIyNEaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIyMiLCJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiMTUwZmEzYjgtZTZjOC00N2ExLTk2ZTAtOTEwNzYzYmVlYzU3In0="
            }
        
            let redirectComponent = AnyRedirectComponentMock()
            redirectComponent.onHandle = { action in
                XCTFail("RedirectComponent should never be invoked.")
            }

            // A mock for the Authentication SDK
            let authenticationServiceMock = AuthenticationServiceMock()
            let onAuthenticateExpectation = expectation(description: "On Authentication - should be called in the AuthneticationSDK")
            authenticationServiceMock.onAuthenticate = { _ in
                onAuthenticateExpectation.fulfill()
                return "onAuthenticate-Return"
            }
            authenticationServiceMock.onRegister = { _ in
                XCTFail("On Register should not be called in the SDK.")
                return "onRegister-Return"
            }

            let delegate = ActionComponentDelegateMock()
        
            // A mock for the one which will present the screens if needed.
            let presentationDelegateMock = PresentationDelegateMock()
        
            // A mock for the 3ds2 sdk
            let mockService = ThreeDSServiceableMock()
            mockService.onResetTransaction = {}
            mockService.onPerformFingerprint = { parameters, completion in
                completion(
                    .success(
                        AuthenticationRequestParametersMock(
                            deviceInformation: "device_info",
                            sdkApplicationIdentifier: "sdkApplicationIdentifier",
                            sdkTransactionIdentifier: "sdkTransactionIdentifier",
                            sdkReferenceNumber: "sdkReferenceNumber",
                            sdkEphemeralPublicKey: "{\"y\":\"zv0kz1SKfNvT3ql75L217de6ZszxfLA8LUKOIKe5Zf4\",\"x\":\"3b3mPfWhuOxwOWydLejS3DJEUPiMVFxtzGCV6906rfc\",\"kty\":\"EC\",\"crv\":\"P-256\"}",
                            messageVersion: "messageVersion"
                        )
                    )
                )
            }
        
            let coreActionHandler = ThreeDS2PlusDACoreActionHandler(
                context: Dummy.context,
                service: mockService,
                presenter: ThreeDS2PlusDAScreenPresenter(
                    style: .init(),
                    localizedParameters: nil,
                    context: Dummy.context
                ),
                theme: .default,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: ""),
                delegatedAuthenticationService: authenticationServiceMock,
                deviceSupportCheckerService: DeviceSupportCheckerMock(isDeviceSupported: true)
            )
            
            let fingerprintSubmitterMock = AnyThreeDS2FingerprintSubmitterMock()
            fingerprintSubmitterMock.onSubmitFingerprint = { fingerprint, paymentData, completionHandler in
                let details = ThreeDSResult(payload: fingerprint)
                completionHandler(.success(.details(details)))
            }
            
            let compactActionHandler = ThreeDS2CompactActionHandler(
                context: Dummy.context,
                fingerprintSubmitter: fingerprintSubmitterMock,
                theme: .default,
                service: mockService,
                coreActionHandler: coreActionHandler,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: "")
            )
        
            let sut = AuthenticationComponent(
                context: Dummy.context,
                threeDS2CompactFlowHandler: compactActionHandler,
                redirectComponent: redirectComponent
            )
            sut.presentationDelegate = presentationDelegateMock
            let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
            delegate.onDidProvide = { data, component in
                XCTAssertTrue(component === sut)
                XCTAssertNil(data.paymentData)

                guard let threeDSResult = data.details as? ThreeDSResult else {
                    XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                    return
                }
                guard let payloadData = Data(base64Encoded: threeDSResult.payload),
                      let json = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: AnyObject] else {
                    XCTFail("Failed to decode payload")
                    return
                }
                guard let delegatedOutput = json["delegatedAuthenticationSDKOutput"] as? String else {
                    XCTFail("Expected delegatedAuthenticationSDKOutput in payload")
                    return
                }
                XCTAssertEqual(delegatedOutput, "onAuthenticate-Return") // Should be the same one returned by the AuthenticationSDK

                delegateExpectation.fulfill()
            }
        
            // Check if the UI is displayed & simulate the tap of the first button which is approve.
            let presentationExpectation = expectation(description: "Approval view controller should be shown.")
            presentationDelegateMock.doPresent = { component in
                let approvalViewController = component.viewController as? DAApprovalViewController
                XCTAssertNotNil(approvalViewController)
                self.verifyApprovalView(viewController: approvalViewController)
                approvalViewController?.firstButtonTapped()
                presentationExpectation.fulfill()
            }

            sut.delegate = delegate
        
            let fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: TestData.fingerprintToken, authorisationToken: "AuthToken", paymentData: "data")
            sut.handle(ThreeDS2Action.fingerprint(fingerprintAction))
        
            waitForExpectations(timeout: 3, handler: nil)
        }
    
        /// Verifies that an authentication error during approval shows the error view and allows fallback.
        func testDADeviceApprovalErrorOnApproving() {
            enum TestData {
                static let fingerprintToken = "eyJkZWxlZ2F0ZWRBdXRoZW50aWNhdGlvblNES0lucHV0IjoiIyNTb21lZGVsZWdhdGVkQXV0aGVudGljYXRpb25TREtJbnB1dCMjIiwiZGlyZWN0b3J5U2VydmVySWQiOiJGMDEzMzcxMzM3IiwiZGlyZWN0b3J5U2VydmVyUHVibGljS2V5IjoiI0RpcmVjdG9yeVNlcnZlclB1YmxpY0tleSMiLCJkaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIjoiIyNEaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIyMiLCJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiMTUwZmEzYjgtZTZjOC00N2ExLTk2ZTAtOTEwNzYzYmVlYzU3In0="
            }
            let rootViewController = UIViewController()
            self.presentOnRoot(rootViewController)

            let redirectComponent = AnyRedirectComponentMock()
            redirectComponent.onHandle = { action in
                XCTFail("RedirectComponent should never be invoked.")
            }

            // A mock for the Authentication SDK
            let authenticationServiceMock = AuthenticationServiceMock()
            let onAuthenticateExpectation = expectation(description: "On Authentication - should be called in the AuthneticationSDK")
            authenticationServiceMock.onAuthenticate = { _ in
                onAuthenticateExpectation.fulfill()
                throw ErrorMock()
            }
            authenticationServiceMock.onRegister = { _ in
                XCTFail("On Register should not be called in the SDK.")
                return "onRegister-Return"
            }

            let delegate = ActionComponentDelegateMock()
        
            // A mock for the one which will present the screens if needed.
            let presentationDelegateMock = PresentationDelegateMock()
        
            // A mock for the 3ds2 sdk
            let mockService = ThreeDSServiceableMock()
            mockService.onResetTransaction = {}
            mockService.onPerformFingerprint = {
                $1(
                    .success(
                        AuthenticationRequestParametersMock(
                            deviceInformation: "device_info",
                            sdkApplicationIdentifier: "sdkApplicationIdentifier",
                            sdkTransactionIdentifier: "sdkTransactionIdentifier",
                            sdkReferenceNumber: "sdkReferenceNumber",
                            sdkEphemeralPublicKey: "{\"y\":\"zv0kz1SKfNvT3ql75L217de6ZszxfLA8LUKOIKe5Zf4\",\"x\":\"3b3mPfWhuOxwOWydLejS3DJEUPiMVFxtzGCV6906rfc\",\"kty\":\"EC\",\"crv\":\"P-256\"}",
                            messageVersion: "messageVersion"
                        )
                    )
                )
            }
        
            let coreActionHandler = ThreeDS2PlusDACoreActionHandler(
                context: Dummy.context,
                service: mockService,
                presenter: ThreeDS2PlusDAScreenPresenter(
                    style: .init(),
                    localizedParameters: nil,
                    context: Dummy.context
                ),
                theme: .default,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: ""),
                delegatedAuthenticationService: authenticationServiceMock,
                deviceSupportCheckerService: DeviceSupportCheckerMock(isDeviceSupported: true)
            )
            
            let fingerprintSubmitterMock = AnyThreeDS2FingerprintSubmitterMock()
            fingerprintSubmitterMock.onSubmitFingerprint = { fingerprint, paymentData, completionHandler in
                let details = ThreeDSResult(payload: fingerprint)
                completionHandler(.success(.details(details)))
            }
            
            let compactActionHandler = ThreeDS2CompactActionHandler(
                context: Dummy.context,
                fingerprintSubmitter: fingerprintSubmitterMock,
                theme: .default,
                service: mockService,
                coreActionHandler: coreActionHandler,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: "")
            )
        
            let sut = AuthenticationComponent(
                context: Dummy.context,
                threeDS2CompactFlowHandler: compactActionHandler,
                redirectComponent: redirectComponent
            )
            sut.presentationDelegate = presentationDelegateMock
            let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
            delegate.onDidProvide = { data, component in
                XCTAssertTrue(component === sut)
                XCTAssertNil(data.paymentData)

                guard let threeDSResult = data.details as? ThreeDSResult else {
                    XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                    return
                }
                guard let payloadData = Data(base64Encoded: threeDSResult.payload),
                      let json = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: AnyObject] else {
                    XCTFail("Failed to decode payload")
                    return
                }
                XCTAssertNil(json["delegatedAuthenticationSDKOutput"])

                delegateExpectation.fulfill()
            }
        
            // Check if the UI is displayed & simulate the tap of the first button which is approve.
            let approvalPresentationExpectation = expectation(description: "Approval view controller should be shown.")
            let approvalErrorPresentationExpectation = expectation(description: "Error on Approval view should be shown.")
            presentationDelegateMock.doPresent = { component in
                if let approvalViewController = component.viewController as? DAApprovalViewController {
                    XCTAssertNotNil(approvalViewController)
                    self.verifyApprovalView(viewController: approvalViewController)
                    approvalPresentationExpectation.fulfill()
                    approvalViewController.firstButtonTapped()
                } else if let errorViewController = component.viewController as? DAErrorViewController {
                    rootViewController.present(errorViewController, animated: false)
                    XCTAssertNotNil(errorViewController)
                    self.verifyApprovalErrorView(controller: errorViewController)
                    errorViewController.troubleshootingButtonTapped()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if let alertController = errorViewController.presentedViewController as? UIAlertController {
                            self.verifyTroubleshootingAlert(controller: alertController)
                        } else {
                            XCTFail("Troubleshooting alert not presented")
                        }
                        approvalErrorPresentationExpectation.fulfill()
                        errorViewController.firstButtonTapped()
                    }
                }
            }

            sut.delegate = delegate
        
            let fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: TestData.fingerprintToken, authorisationToken: "AuthToken", paymentData: "data")
            sut.handle(ThreeDS2Action.fingerprint(fingerprintAction))
            wait(
                for: [
                    approvalPresentationExpectation,
                    onAuthenticateExpectation,
                    approvalErrorPresentationExpectation,
                    delegateExpectation
                ],
                timeout: 2,
                enforceOrder: true
            )
        }
    
        /// Verifies that the delegated authentication registration flow succeeds when user opts in.
        func testDelegatedAuthenticationRegistrationFlow() {
            enum TestData {
                static let challengeToken = "eyJkZWxlZ2F0ZWRBdXRoZW50aWNhdGlvblNES0lucHV0IjogImV5SmphR0ZzYkdWdVoyVWlPaUpqYUdGc2JHVnVaMlVpZlEiLCAiYWNzUmVmZXJlbmNlTnVtYmVyIjoiQURZRU4tQUNTLVNJTVVMQVRPUiIsImFjc1NpZ25lZENvbnRlbnQiOiJleUpoYkdjaU9pSlFVekkxTmlJc0luZzFZeUk2V3lKTlNVbEVNMFJEUTBGelVVTkRVVVJVU205VFZHeFlXQzlQVkVGT1FtZHJjV2hyYVVjNWR6QkNRVkZ6UmtGRVEwSjFha1ZNVFVGclIwRXhWVVZDYUUxRFZHdDNlRVpxUVZWQ1owNVdRa0ZuVFVSVk5YWmlNMHByVEZWb2RtSkhlR2hpYlZGNFJXcEJVVUpuVGxaQ1FXTk5RMVZHZEdNelVteGpiVkpvWWxSRlZFMUNSVWRCTVZWRlEyZDNTMUZYVWpWYVZ6Um5WR2sxVjB4cVJWSk5RVGhIUVRGVlJVTjNkMGxSTW1oc1dUSjBkbVJZVVhoT1ZFRjZRbWRPVmtKQlRVMU1SRTVGVlhwSloxVXliSFJrVjNob1pFYzVlVWxHV2twVk1FVm5Va1pOWjFFeVZubGtSMnh0WVZkT2FHUkhWV2RSV0ZZd1lVYzVlV0ZZVWpWTlUwRjNTR2RaU2t0dldrbG9kbU5PUVZGclFrWm9SbnBrV0VKM1lqTktNRkZIUm10bFYxWjFURzFPZG1KVVFXVkdkekI0VDBSQk5FMXFZM2hOZWxGNlRWUlNZVVozTUhsUFJFRTBUV3BSZUUxNlVYcE5WRkpoVFVsSGEwMVJjM2REVVZsRVZsRlJSMFYzU2s5VVJFVlhUVUpSUjBFeFZVVkRRWGRPVkcwNWRtTnRVWFJUUnpsellrZEdkVnBFUlZOTlFrRkhRVEZWUlVKM2QwcFJWekY2WkVkV2VWcEhSblJOVWsxM1JWRlpSRlpSVVV0RVFYQkNXa2hzYkdKcFFrOU1iRmwxVFZKRmQwUjNXVVJXVVZGTVJFRm9SR0ZIVm1waE1qa3haRVJGWmsxQ01FZEJNVlZGUVhkM1YwMHdVbFJOYVVKVVlWY3hNV0pIUmpCaU0wbG5WbXRzVkZGVFFrVlZla1ZuVFVJMFIwTlRjVWRUU1dJelJGRkZTa0ZTV1ZKak0xWjNZMGM1ZVdSRlFtaGFTR3hzWW1rMWFtSXlNSGRuWjBWcFRVRXdSME5UY1VkVFNXSXpSRkZGUWtGUlZVRkJORWxDUkhkQmQyZG5SVXRCYjBsQ1FWRkRZeTlYZDA0MlpuWXhZVWwxYTNwTmFGZGhVbVJhWjBRNVVHdDFOV0Y1VFdWaGJXeE9SelIwVld3eVV6WTNURXRFT1VKU2VXTm9RWFp2TlVFclJXdG1Na2hMVWpKWVZHVnhUMlpIWm05TVJFbHhNa3hYUnpsSGEwdHlSeTlMUW5RdlFWQkVNWGhDYUdkdFNHNXJORmxxY0VGV2JsQTBabUZLVEhSU2NXRlFSVVZPVHpnd2JXTjZXV3hoZHpoWmFuUlJObmxJV0ZCTk5FOVBMMlo2TjJZMU9GRmxjRWhoZFUxYWNIcDZlazByUkc5dFZEQk1NVWhDYkZoVWVGcG5kVlpETUM5MVpVUk5ZMU5SVFdZNFQzSldZa3hVZHpOa1FubEVPRmQ1TlhkNFFXZFJkbFl2UkdaRWVWRllXamRMUTFabVpqbDFaVkZZYmtSdVQzbEdNRTVoTDBKSlZXMXFlbWgyU205R1kxZzJVeTg0V1V3MmRtSnBNMjVrWVhsTFdXdHVkRFZ2Y1RKb1ZrZG1hRm9yYURVM2VWbzNabmxXWmtJd2MyRlFhRkZyTTBjMlNqQlBLMHBzTWxWWE9GRjJRVFl3VmpoNk5HWkJaMDFDUVVGRmQwUlJXVXBMYjFwSmFIWmpUa0ZSUlV4Q1VVRkVaMmRGUWtGSFVVeGpVRzlRTkRoQllVTnlVV0p4ZWl0MlJsQTBNbWx5YjJKR1VHWnhjRlZyWkZZMlFVeE5lRXBDWTJOMlNEbENibHBuVmxKNkwzRk9UbE0yUlVnMmJIWnZabGt3YkVoVGRVdGthMEo0TDFCV09FcE9jR1JvYldNdllVTkZTM2RtY1dsMFZuWndNemxFUnpsTlVrcFZNWG8zYlhRdlVsSklTbWxWUkRGR01WRlJlR0pUT0dSTWJXOTBTR1pOU1dsVmR5OXpVWEpXWm1WRU5sQk1VRGxxUTNrdlZXbDFkMlZIWTNOaWFGRXpiekJJUVdjeGRrbDJUVUpXU0RKaWNDdG1iREJpUVhFNVRHczBXWGhCTUVSdlMyTklZbGhtUTBWS2J6ZFBMM1JMV1d4YVoxcHJOVk5rUzFGbGNFTmhWRkV6Tmk5V2IxUnliSHBKTUU5d1ZVY3hkSEpGT1dWVk1TdEpOa3hxTVU5bFpYbGtaalU1Wm5aWVFXUm9MMmhrWkdoTFZEUm5TbkoyZGtaaU1IYzBlbHBwV0hWNlZscFFTMUF3ZG5sclFXNDVLMGsyUVZJeVVrczRZVUUwTkc5S1FVd3pkMGd4U1VFOUlpd2lUVWxKUkRocVEwTkJkRzlEUTFGRVRtNVllV05XUlVsM2RYcEJUa0puYTNGb2EybEhPWGN3UWtGUmMwWkJSRU5DZFdwRlRFMUJhMGRCTVZWRlFtaE5RMVJyZDNoR2FrRlZRbWRPVmtKQlowMUVWVFYyWWpOS2EweFZhSFppUjNob1ltMVJlRVZxUVZGQ1owNVdRa0ZqVFVOVlJuUmpNMUpzWTIxU2FHSlVSVlJOUWtWSFFURlZSVU5uZDB0UlYxSTFXbGMwWjFScE5WZE1ha1ZTVFVFNFIwRXhWVVZEZDNkSlVUSm9iRmt5ZEhaa1dGRjRUbFJCZWtKblRsWkNRVTFOVEVST1JWVjZTV2RWTW14MFpGZDRhR1JIT1hsSlJscEtWVEJGWjFKR1RXZFJNbFo1WkVkc2JXRlhUbWhrUjFWblVWaFdNR0ZIT1hsaFdGSTFUVk5CZDBobldVcExiMXBKYUhaalRrRlJhMEpHYUVaNlpGaENkMkl6U2pCUlIwWnJaVmRXZFV4dFRuWmlWRUZsUm5jd2VFOUVRVFJOYW1ONFRYcFJkMDVVYUdGR2R6QjVUMFJCTkUxcVVYaE5lbEYzVGxSb1lVMUpSelpOVVhOM1ExRlpSRlpSVVVkRmQwcFBWRVJGVjAxQ1VVZEJNVlZGUTBGM1RsUnRPWFpqYlZGMFUwYzVjMkpIUm5WYVJFVlRUVUpCUjBFeFZVVkNkM2RLVVZjeGVtUkhWbmxhUjBaMFRWSk5kMFZSV1VSV1VWRkxSRUZ3UWxwSWJHeGlhVUpQVEd4WmRVMVNSWGRFZDFsRVZsRlJURVJCYUVSaFIxWnFZVEk1TVdSRVJURk5SRTFIUVRGVlJVRjNkM05OTUZKVVRXbENWR0ZYTVRGaVIwWXdZak5KWjFacmJGUlJVMEpGVlhsQ1JGcFlTakJoVjFwd1dUSkdNRnBUUWtKa1dGSnZZak5LY0dSSWEzaEpSRUZsUW1kcmNXaHJhVWM1ZHpCQ1ExRkZWMFZZVGpGalNFSjJZMjVTUVZsWFVqVmFWelIxV1RJNWRFMUpTVUpKYWtGT1FtZHJjV2hyYVVjNWR6QkNRVkZGUmtGQlQwTkJVVGhCVFVsSlFrTm5TME5CVVVWQmRYQTNLMlowZDFkblIyUmpZVFl4Y1ZaQ1l6RkNkbFJwTlZrME0wSjNhRm96VTJoS1NXdHRSMGwzWjFsUWMwbzVjSEpQWTFwVlZtVkhhMFZvWXpWSFdIY3ZPVkpNWTJ4WmJXbHBNbG92VEZCRmVYazJWVWxqVUhORlJtbGtVbnBYVERaa09EUmlaR0k0VkRWcE5rbEJUSE5JVTJkUFptTlFUekpFUTFsdlRqVkdLMGd2ZGxWaGNIZFpSMnBDTkZrcmFYZE5abEV5WlhOTU0xRkVaRVVyTDI4NUwxbzBUbkJtYnprclkyWXhSSHBsY0ZOWFZuaFVlRkpTYTFOWU1VY3JVWFpyUWswdmNHeDBOVzAxZUN0TVZWa3dlalpWTkN0MVVYRkNVVmx6YVRCVlVEVk5iV0k0UlRaVmQwY3lhMk00Tm5SelpYYzBXVXh4VTJOWWRGVTVaeTl2T1Rsbk9VVnJia1ZUV205Q09GRnRhbWRKTUhOYVVYSkZNMHR2TkVFeUwxbERaVEkxU21kYU56RkxZemRGTHpsSVMxRkxNMVl4ZEdsTWNucDRhVk5MTUhFNFlrVk9NMnBoWWpSelVVcFhZM3BTTlU1UlNVUkJVVUZDVFVFd1IwTlRjVWRUU1dJelJGRkZRa04zVlVGQk5FbENRVkZCYlRoeFQwUkJUa0l6VUhBck9UaFJablZSVlVWVVdHVXhUbEp3U25aRWIyTjVjMlJ2U2l0emREaEhXbVJpVjJsdWEwOXdOMlpzV1RSWWNFWnlNbHBKY1U1SVRYbEtjMlkzT1VsQlMyeENaVzlUV0RkNFZHWnFaM0l5T0hkbmExTjVkRFZRVjJJM1drWXpXRlF3Ym1kWGMzaHlNbVIwUmpkU2RVRjRVVGhLWWxSd1VFeGtSVmt4V2pKeWFFbzFZWFJLZERkRlNsbEZOa0ZZU25wQmNqVlZTamQ1YlRCaldTczVUazB6VmtKcVUzQmpPV1ZNVDA0elZHdFpXRzlWZGpKa2JVdDFNVWg2VEhaaU1XMUVNR1ZJZVhWRmNsRlBjbUpVS3pGdlJrMWxMMHRvZW5ZeE4weHJXRGhxTjA5NFUwdHRVaTlJTDFReWVYRm5iWHBQZUdkTk1HeExlbXN6VjJsUlQyNHhhMVJYWVc5WU9FTm9VRFpwVTIxS2EzSjNTVlY1V2l0V01WVkpVRU5VYm5Sc1VYcEZVVXBJT1RaUk5XNVpUbFJNVGpocVZteHdOVzF1UzBkMFVrRlljbXgxY25oTWFUbFpOa1VpWFgwLmV5SmhZM05GY0dobGJWQjFZa3RsZVNJNmV5SmpjbllpT2lKUUxUSTFOaUlzSW10MGVTSTZJa1ZESWl3aWVDSTZJbWRKTUVkQlNVeENaSFUzVkRVellXdHlSbTFOZVVkamMwWXpialZrVHpkTmJYZE9Ra2hMVnpWVFZqQWlMQ0o1SWpvaVUweFhYM2hUWm1aNmJGQlhja2hGVmtrek1FUklUVjgwWldkV2QzUXpUbEZ4WlZWRU4yNU5SbkJ3Y3lKOUxDSnpaR3RGY0dobGJWQjFZa3RsZVNJNmV5SmpjbllpT2lKUUxUSTFOaUlzSW10MGVTSTZJa1ZESWl3aWVDSTZJa1ozUldGc1prOTZRV1l0YmpaRU5GRjJSRnBHZG1oU2FEVm5ORkJIWm00NVYzcEVWelZSTkZNeU1VVWlMQ0o1SWpvaVJrYzBiMDFXTjJ0dWNUSllSVEZHVFRsUE0zb3hTVXBPTWxNeE9FSk9RVTB0ZGt0SFRXeDNjbU5UV1NKOUxDSmhZM05WVWt3aU9pSm9kSFJ3Y3pwY0wxd3ZjR0ZzTFhSbGMzUXVZV1I1Wlc0dVkyOXRYQzkwYUhKbFpXUnpNbk5wYlhWc1lYUnZjbHd2YzJWeWRtbGpaWE5jTDFSb2NtVmxSRk15VTJsdGRXeGhkRzl5WEM5Mk1Wd3ZhR0Z1Wkd4bFhDOHlOR1ZsTnpJME1pMHhaRGcxTFRRNFpHTXRPREV6WWkwM01EaGhOVFl3Wm1WaVpUVWlmUS5UM0pSUUg4UlkwNzYta1BCRGl1LU9lRlJLcEtyX0tfX3RCdUxscnZSeWlsc3JxMHA2dzVMcGM2STVXMHE1V1Awbk5hUmE2VFdYMWZVc1g2Rldhbk5LYzJXczRWYk0zejg5M3BjRFNSZVZYWVp3eWs5WnZzaWhRNzAzQjJoTzNQbXZPM09QT0VTWi1xRGFJckRLRkVHUEdSQnVwQlhUVmVRaFNkdUlPOWpUekxEZW5NZGdEMlFDNU9BR3VTTEVKN0o4VnFiM0htV0k4bGZJLWNQQ3YxSkpEY3YxMWJ2ZEZOVC1WNzVIT0xGNjN2WGY3UkxhZTVLbFQwalJtMW93NDFTMG9Td3lrN1BjeTBvN3A0S0o2LWxGaGRvc2ZEVGJQWXp5VkprSHdfR0J2YzhNNWU2QV8zcUdtbWJtYjlvaUJkWC1taEtJc0RrVkI4bW5CbkdKdzRRY0EiLCJhY3NUcmFuc0lEIjoiMjRlZTcyNDItMWQ4NS00OGRjLTgxM2ItNzA4YTU2MGZlYmU1IiwiYWNzVVJMIjoiaHR0cHM6XC9cL3BhbC10ZXN0LmFkeWVuLmNvbVwvdGhyZWVkczJzaW11bGF0b3JcL3NlcnZpY2VzXC9UaHJlZURTMlNpbXVsYXRvclwvdjFcL2hhbmRsZVwvMjRlZTcyNDItMWQ4NS00OGRjLTgxM2ItNzA4YTU2MGZlYmU1IiwibWVzc2FnZVZlcnNpb24iOiIyLjEuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiN2IyNjBkNzMtNzE2NC00MWNkLWE3MGMtOGFhOGQxYTFjOWEyIn0="
            }
        
            let redirectComponent = AnyRedirectComponentMock()
            redirectComponent.onHandle = { action in
                XCTFail("RedirectComponent should never be invoked.")
            }

            // A mock for the Authentication SDK
            let authenticationServiceMock = AuthenticationServiceMock()
            authenticationServiceMock.isDeviceRegistered = false
            authenticationServiceMock.onAuthenticate = { _ in
                XCTFail("On Authentication should not be called in a register flow")
                return "onAuthenticate-Return"
            }
            let onRegisterExpectation = expectation(description: "On Authentication - should be called in the AuthneticationSDK")
            authenticationServiceMock.onRegister = { _ in
                onRegisterExpectation.fulfill()
                return "onRegister-Return"
            }
        
            let delegate = ActionComponentDelegateMock()
        
            // A mock for the one which will present the screens if needed.
            let presentationDelegateMock = PresentationDelegateMock()
        
            // A mock for the 3ds2 sdk, which would successfully complete a challenge.
            let mockService = ThreeDSServiceableMock()
            mockService.onResetTransaction = {}
            let authenticationRequestParameters = AuthenticationRequestParametersMock(
                deviceInformation: "device_info",
                sdkApplicationIdentifier: "sdkApplicationIdentifier",
                sdkTransactionIdentifier: "sdkTransactionIdentifier",
                sdkReferenceNumber: "sdkReferenceNumber",
                sdkEphemeralPublicKey: "{\"y\":\"zv0kz1SKfNvT3ql75L217de6ZszxfLA8LUKOIKe5Zf4\",\"x\":\"3b3mPfWhuOxwOWydLejS3DJEUPiMVFxtzGCV6906rfc\",\"kty\":\"EC\",\"crv\":\"P-256\"}",
                messageVersion: "messageVersion"
            )
            mockService.onPerformFingerprint = { $1(.success(authenticationRequestParameters)) }

            let coreActionHandler = ThreeDS2PlusDACoreActionHandler(
                context: Dummy.context,
                service: mockService,
                presenter: ThreeDS2PlusDAScreenPresenter(
                    style: .init(),
                    localizedParameters: nil,
                    context: Dummy.context
                ),
                theme: .default,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: ""),
                delegatedAuthenticationService: authenticationServiceMock,
                deviceSupportCheckerService: DeviceSupportCheckerMock(isDeviceSupported: true)
            )
            coreActionHandler.delegatedAuthenticationState.attemptRegistration = true
            
            let compactActionHandler = ThreeDS2CompactActionHandler(
                context: Dummy.context,
                fingerprintSubmitter: AnyThreeDS2FingerprintSubmitterMock(),
                theme: .default,
                service: mockService,
                coreActionHandler: coreActionHandler,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: "")
            )
            mockService.onPerformChallenge = { $1(.success(AnyChallengeResultMock(sdkTransactionIdentifier: "sdkTxId", transactionStatus: "Y"))) }
            let sut = AuthenticationComponent(
                context: Dummy.context,
                threeDS2CompactFlowHandler: compactActionHandler,
                redirectComponent: redirectComponent
            )
            sut.presentationDelegate = presentationDelegateMock
            // Verify if we get a challengeResult.
            let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
            delegate.onDidProvide = { data, component in
                XCTAssertTrue(component === sut)
                XCTAssertNil(data.paymentData)

                guard let threeDSResult = data.details as? ThreeDSResult else {
                    XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                    return
                }
                XCTAssertEqual(threeDSResult.payload, "eyJhdXRob3Jpc2F0aW9uVG9rZW4iOiJhdXRoVG9rZW4iLCJkZWxlZ2F0ZWRBdXRoZW50aWNhdGlvblNES091dHB1dCI6Im9uUmVnaXN0ZXItUmV0dXJuIiwidHJhbnNTdGF0dXMiOiJZIn0=")

                delegateExpectation.fulfill()
            }
        
            // Verify if the UI is displayed & simulate the tap of the first button which is approve.
            let presentationExpectation = expectation(description: "Approval view controller should be shown.")
            presentationDelegateMock.doPresent = { component in
                let registrationViewController = component.viewController as? DARegistrationViewController
                self.verifyRegistrationView(viewController: registrationViewController)
                XCTAssertNotNil(registrationViewController)
                registrationViewController?.firstButtonTapped()
                presentationExpectation.fulfill()
            }

            sut.delegate = delegate
        
            // execute a challenge - as the registration flow is triggered only during a challenge flow.
            sut.handle(ThreeDS2Action.challenge(ThreeDS2ChallengeAction(challengeToken: TestData.challengeToken, authorisationToken: "authToken", paymentData: "paymentData")))

            waitForExpectations(timeout: 3, handler: nil)
        }

        /// Verifies that a registration error shows the error view and completes without DA output.
        func testDelegatedAuthenticationRegisterError() {
            enum TestData {
                static let challengeToken = "eyJkZWxlZ2F0ZWRBdXRoZW50aWNhdGlvblNES0lucHV0IjogImV5SmphR0ZzYkdWdVoyVWlPaUpqYUdGc2JHVnVaMlVpZlEiLCAiYWNzUmVmZXJlbmNlTnVtYmVyIjoiQURZRU4tQUNTLVNJTVVMQVRPUiIsImFjc1NpZ25lZENvbnRlbnQiOiJleUpoYkdjaU9pSlFVekkxTmlJc0luZzFZeUk2V3lKTlNVbEVNMFJEUTBGelVVTkRVVVJVU205VFZHeFlXQzlQVkVGT1FtZHJjV2hyYVVjNWR6QkNRVkZ6UmtGRVEwSjFha1ZNVFVGclIwRXhWVVZDYUUxRFZHdDNlRVpxUVZWQ1owNVdRa0ZuVFVSVk5YWmlNMHByVEZWb2RtSkhlR2hpYlZGNFJXcEJVVUpuVGxaQ1FXTk5RMVZHZEdNelVteGpiVkpvWWxSRlZFMUNSVWRCTVZWRlEyZDNTMUZYVWpWYVZ6Um5WR2sxVjB4cVJWSk5RVGhIUVRGVlJVTjNkMGxSTW1oc1dUSjBkbVJZVVhoT1ZFRjZRbWRPVmtKQlRVMU1SRTVGVlhwSloxVXliSFJrVjNob1pFYzVlVWxHV2twVk1FVm5Va1pOWjFFeVZubGtSMnh0WVZkT2FHUkhWV2RSV0ZZd1lVYzVlV0ZZVWpWTlUwRjNTR2RaU2t0dldrbG9kbU5PUVZGclFrWm9SbnBrV0VKM1lqTktNRkZIUm10bFYxWjFURzFPZG1KVVFXVkdkekI0VDBSQk5FMXFZM2hOZWxGNlRWUlNZVVozTUhsUFJFRTBUV3BSZUUxNlVYcE5WRkpoVFVsSGEwMVJjM2REVVZsRVZsRlJSMFYzU2s5VVJFVlhUVUpSUjBFeFZVVkRRWGRPVkcwNWRtTnRVWFJUUnpsellrZEdkVnBFUlZOTlFrRkhRVEZWUlVKM2QwcFJWekY2WkVkV2VWcEhSblJOVWsxM1JWRlpSRlpSVVV0RVFYQkNXa2hzYkdKcFFrOU1iRmwxVFZKRmQwUjNXVVJXVVZGTVJFRm9SR0ZIVm1waE1qa3haRVJGWmsxQ01FZEJNVlZGUVhkM1YwMHdVbFJOYVVKVVlWY3hNV0pIUmpCaU0wbG5WbXRzVkZGVFFrVlZla1ZuVFVJMFIwTlRjVWRUU1dJelJGRkZTa0ZTV1ZKak0xWjNZMGM1ZVdSRlFtaGFTR3hzWW1rMWFtSXlNSGRuWjBWcFRVRXdSME5UY1VkVFNXSXpSRkZGUWtGUlZVRkJORWxDUkhkQmQyZG5SVXRCYjBsQ1FWRkRZeTlYZDA0MlpuWXhZVWwxYTNwTmFGZGhVbVJhWjBRNVVHdDFOV0Y1VFdWaGJXeE9SelIwVld3eVV6WTNURXRFT1VKU2VXTm9RWFp2TlVFclJXdG1Na2hMVWpKWVZHVnhUMlpIWm05TVJFbHhNa3hYUnpsSGEwdHlSeTlMUW5RdlFWQkVNWGhDYUdkdFNHNXJORmxxY0VGV2JsQTBabUZLVEhSU2NXRlFSVVZPVHpnd2JXTjZXV3hoZHpoWmFuUlJObmxJV0ZCTk5FOVBMMlo2TjJZMU9GRmxjRWhoZFUxYWNIcDZlazByUkc5dFZEQk1NVWhDYkZoVWVGcG5kVlpETUM5MVpVUk5ZMU5SVFdZNFQzSldZa3hVZHpOa1FubEVPRmQ1TlhkNFFXZFJkbFl2UkdaRWVWRllXamRMUTFabVpqbDFaVkZZYmtSdVQzbEdNRTVoTDBKSlZXMXFlbWgyU205R1kxZzJVeTg0V1V3MmRtSnBNMjVrWVhsTFdXdHVkRFZ2Y1RKb1ZrZG1hRm9yYURVM2VWbzNabmxXWmtJd2MyRlFhRkZyTTBjMlNqQlBLMHBzTWxWWE9GRjJRVFl3VmpoNk5HWkJaMDFDUVVGRmQwUlJXVXBMYjFwSmFIWmpUa0ZSUlV4Q1VVRkVaMmRGUWtGSFVVeGpVRzlRTkRoQllVTnlVV0p4ZWl0MlJsQTBNbWx5YjJKR1VHWnhjRlZyWkZZMlFVeE5lRXBDWTJOMlNEbENibHBuVmxKNkwzRk9UbE0yUlVnMmJIWnZabGt3YkVoVGRVdGthMEo0TDFCV09FcE9jR1JvYldNdllVTkZTM2RtY1dsMFZuWndNemxFUnpsTlVrcFZNWG8zYlhRdlVsSklTbWxWUkRGR01WRlJlR0pUT0dSTWJXOTBTR1pOU1dsVmR5OXpVWEpXWm1WRU5sQk1VRGxxUTNrdlZXbDFkMlZIWTNOaWFGRXpiekJJUVdjeGRrbDJUVUpXU0RKaWNDdG1iREJpUVhFNVRHczBXWGhCTUVSdlMyTklZbGhtUTBWS2J6ZFBMM1JMV1d4YVoxcHJOVk5rUzFGbGNFTmhWRkV6Tmk5V2IxUnliSHBKTUU5d1ZVY3hkSEpGT1dWVk1TdEpOa3hxTVU5bFpYbGtaalU1Wm5aWVFXUm9MMmhrWkdoTFZEUm5TbkoyZGtaaU1IYzBlbHBwV0hWNlZscFFTMUF3ZG5sclFXNDVLMGsyUVZJeVVrczRZVUUwTkc5S1FVd3pkMGd4U1VFOUlpd2lUVWxKUkRocVEwTkJkRzlEUTFGRVRtNVllV05XUlVsM2RYcEJUa0puYTNGb2EybEhPWGN3UWtGUmMwWkJSRU5DZFdwRlRFMUJhMGRCTVZWRlFtaE5RMVJyZDNoR2FrRlZRbWRPVmtKQlowMUVWVFYyWWpOS2EweFZhSFppUjNob1ltMVJlRVZxUVZGQ1owNVdRa0ZqVFVOVlJuUmpNMUpzWTIxU2FHSlVSVlJOUWtWSFFURlZSVU5uZDB0UlYxSTFXbGMwWjFScE5WZE1ha1ZTVFVFNFIwRXhWVVZEZDNkSlVUSm9iRmt5ZEhaa1dGRjRUbFJCZWtKblRsWkNRVTFOVEVST1JWVjZTV2RWTW14MFpGZDRhR1JIT1hsSlJscEtWVEJGWjFKR1RXZFJNbFo1WkVkc2JXRlhUbWhrUjFWblVWaFdNR0ZIT1hsaFdGSTFUVk5CZDBobldVcExiMXBKYUhaalRrRlJhMEpHYUVaNlpGaENkMkl6U2pCUlIwWnJaVmRXZFV4dFRuWmlWRUZsUm5jd2VFOUVRVFJOYW1ONFRYcFJkMDVVYUdGR2R6QjVUMFJCTkUxcVVYaE5lbEYzVGxSb1lVMUpSelpOVVhOM1ExRlpSRlpSVVVkRmQwcFBWRVJGVjAxQ1VVZEJNVlZGUTBGM1RsUnRPWFpqYlZGMFUwYzVjMkpIUm5WYVJFVlRUVUpCUjBFeFZVVkNkM2RLVVZjeGVtUkhWbmxhUjBaMFRWSk5kMFZSV1VSV1VWRkxSRUZ3UWxwSWJHeGlhVUpQVEd4WmRVMVNSWGRFZDFsRVZsRlJURVJCYUVSaFIxWnFZVEk1TVdSRVJURk5SRTFIUVRGVlJVRjNkM05OTUZKVVRXbENWR0ZYTVRGaVIwWXdZak5KWjFacmJGUlJVMEpGVlhsQ1JGcFlTakJoVjFwd1dUSkdNRnBUUWtKa1dGSnZZak5LY0dSSWEzaEpSRUZsUW1kcmNXaHJhVWM1ZHpCQ1ExRkZWMFZZVGpGalNFSjJZMjVTUVZsWFVqVmFWelIxV1RJNWRFMUpTVUpKYWtGT1FtZHJjV2hyYVVjNWR6QkNRVkZGUmtGQlQwTkJVVGhCVFVsSlFrTm5TME5CVVVWQmRYQTNLMlowZDFkblIyUmpZVFl4Y1ZaQ1l6RkNkbFJwTlZrME0wSjNhRm96VTJoS1NXdHRSMGwzWjFsUWMwbzVjSEpQWTFwVlZtVkhhMFZvWXpWSFdIY3ZPVkpNWTJ4WmJXbHBNbG92VEZCRmVYazJWVWxqVUhORlJtbGtVbnBYVERaa09EUmlaR0k0VkRWcE5rbEJUSE5JVTJkUFptTlFUekpFUTFsdlRqVkdLMGd2ZGxWaGNIZFpSMnBDTkZrcmFYZE5abEV5WlhOTU0xRkVaRVVyTDI4NUwxbzBUbkJtYnprclkyWXhSSHBsY0ZOWFZuaFVlRkpTYTFOWU1VY3JVWFpyUWswdmNHeDBOVzAxZUN0TVZWa3dlalpWTkN0MVVYRkNVVmx6YVRCVlVEVk5iV0k0UlRaVmQwY3lhMk00Tm5SelpYYzBXVXh4VTJOWWRGVTVaeTl2T1Rsbk9VVnJia1ZUV205Q09GRnRhbWRKTUhOYVVYSkZNMHR2TkVFeUwxbERaVEkxU21kYU56RkxZemRGTHpsSVMxRkxNMVl4ZEdsTWNucDRhVk5MTUhFNFlrVk9NMnBoWWpSelVVcFhZM3BTTlU1UlNVUkJVVUZDVFVFd1IwTlRjVWRUU1dJelJGRkZRa04zVlVGQk5FbENRVkZCYlRoeFQwUkJUa0l6VUhBck9UaFJablZSVlVWVVdHVXhUbEp3U25aRWIyTjVjMlJ2U2l0emREaEhXbVJpVjJsdWEwOXdOMlpzV1RSWWNFWnlNbHBKY1U1SVRYbEtjMlkzT1VsQlMyeENaVzlUV0RkNFZHWnFaM0l5T0hkbmExTjVkRFZRVjJJM1drWXpXRlF3Ym1kWGMzaHlNbVIwUmpkU2RVRjRVVGhLWWxSd1VFeGtSVmt4V2pKeWFFbzFZWFJLZERkRlNsbEZOa0ZZU25wQmNqVlZTamQ1YlRCaldTczVUazB6VmtKcVUzQmpPV1ZNVDA0elZHdFpXRzlWZGpKa2JVdDFNVWg2VEhaaU1XMUVNR1ZJZVhWRmNsRlBjbUpVS3pGdlJrMWxMMHRvZW5ZeE4weHJXRGhxTjA5NFUwdHRVaTlJTDFReWVYRm5iWHBQZUdkTk1HeExlbXN6VjJsUlQyNHhhMVJYWVc5WU9FTm9VRFpwVTIxS2EzSjNTVlY1V2l0V01WVkpVRU5VYm5Sc1VYcEZVVXBJT1RaUk5XNVpUbFJNVGpocVZteHdOVzF1UzBkMFVrRlljbXgxY25oTWFUbFpOa1VpWFgwLmV5SmhZM05GY0dobGJWQjFZa3RsZVNJNmV5SmpjbllpT2lKUUxUSTFOaUlzSW10MGVTSTZJa1ZESWl3aWVDSTZJbWRKTUVkQlNVeENaSFUzVkRVellXdHlSbTFOZVVkamMwWXpialZrVHpkTmJYZE9Ra2hMVnpWVFZqQWlMQ0o1SWpvaVUweFhYM2hUWm1aNmJGQlhja2hGVmtrek1FUklUVjgwWldkV2QzUXpUbEZ4WlZWRU4yNU5SbkJ3Y3lKOUxDSnpaR3RGY0dobGJWQjFZa3RsZVNJNmV5SmpjbllpT2lKUUxUSTFOaUlzSW10MGVTSTZJa1ZESWl3aWVDSTZJa1ozUldGc1prOTZRV1l0YmpaRU5GRjJSRnBHZG1oU2FEVm5ORkJIWm00NVYzcEVWelZSTkZNeU1VVWlMQ0o1SWpvaVJrYzBiMDFXTjJ0dWNUSllSVEZHVFRsUE0zb3hTVXBPTWxNeE9FSk9RVTB0ZGt0SFRXeDNjbU5UV1NKOUxDSmhZM05WVWt3aU9pSm9kSFJ3Y3pwY0wxd3ZjR0ZzTFhSbGMzUXVZV1I1Wlc0dVkyOXRYQzkwYUhKbFpXUnpNbk5wYlhWc1lYUnZjbHd2YzJWeWRtbGpaWE5jTDFSb2NtVmxSRk15VTJsdGRXeGhkRzl5WEM5Mk1Wd3ZhR0Z1Wkd4bFhDOHlOR1ZsTnpJME1pMHhaRGcxTFRRNFpHTXRPREV6WWkwM01EaGhOVFl3Wm1WaVpUVWlmUS5UM0pSUUg4UlkwNzYta1BCRGl1LU9lRlJLcEtyX0tfX3RCdUxscnZSeWlsc3JxMHA2dzVMcGM2STVXMHE1V1Awbk5hUmE2VFdYMWZVc1g2Rldhbk5LYzJXczRWYk0zejg5M3BjRFNSZVZYWVp3eWs5WnZzaWhRNzAzQjJoTzNQbXZPM09QT0VTWi1xRGFJckRLRkVHUEdSQnVwQlhUVmVRaFNkdUlPOWpUekxEZW5NZGdEMlFDNU9BR3VTTEVKN0o4VnFiM0htV0k4bGZJLWNQQ3YxSkpEY3YxMWJ2ZEZOVC1WNzVIT0xGNjN2WGY3UkxhZTVLbFQwalJtMW93NDFTMG9Td3lrN1BjeTBvN3A0S0o2LWxGaGRvc2ZEVGJQWXp5VkprSHdfR0J2YzhNNWU2QV8zcUdtbWJtYjlvaUJkWC1taEtJc0RrVkI4bW5CbkdKdzRRY0EiLCJhY3NUcmFuc0lEIjoiMjRlZTcyNDItMWQ4NS00OGRjLTgxM2ItNzA4YTU2MGZlYmU1IiwiYWNzVVJMIjoiaHR0cHM6XC9cL3BhbC10ZXN0LmFkeWVuLmNvbVwvdGhyZWVkczJzaW11bGF0b3JcL3NlcnZpY2VzXC9UaHJlZURTMlNpbXVsYXRvclwvdjFcL2hhbmRsZVwvMjRlZTcyNDItMWQ4NS00OGRjLTgxM2ItNzA4YTU2MGZlYmU1IiwibWVzc2FnZVZlcnNpb24iOiIyLjEuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiN2IyNjBkNzMtNzE2NC00MWNkLWE3MGMtOGFhOGQxYTFjOWEyIn0="
            }
    
            let redirectComponent = AnyRedirectComponentMock()
            redirectComponent.onHandle = { action in
                XCTFail("RedirectComponent should never be invoked.")
            }

            // A mock for the Authentication SDK
            let authenticationServiceMock = AuthenticationServiceMock()
            authenticationServiceMock.isDeviceRegistered = false
            authenticationServiceMock.onAuthenticate = { _ in
                XCTFail("On Authentication should not be called in a register flow")
                return "onAuthenticate-Return"
            }
            let onRegisterExpectation = expectation(description: "On Registration - should be called in the AuthneticationSDK")
            authenticationServiceMock.onRegister = { _ in
                onRegisterExpectation.fulfill()
                throw ErrorMock()
            }
    
            let delegate = ActionComponentDelegateMock()
    
            // A mock for the one which will present the screens if needed.
            let presentationDelegateMock = PresentationDelegateMock()
    
            // A mock for the 3ds2 sdk, which would successfully complete a challenge.
            let mockService = ThreeDSServiceableMock()
            mockService.onResetTransaction = {}
            let authenticationRequestParameters = AuthenticationRequestParametersMock(
                deviceInformation: "device_info",
                sdkApplicationIdentifier: "sdkApplicationIdentifier",
                sdkTransactionIdentifier: "sdkTransactionIdentifier",
                sdkReferenceNumber: "sdkReferenceNumber",
                sdkEphemeralPublicKey: "{\"y\":\"zv0kz1SKfNvT3ql75L217de6ZszxfLA8LUKOIKe5Zf4\",\"x\":\"3b3mPfWhuOxwOWydLejS3DJEUPiMVFxtzGCV6906rfc\",\"kty\":\"EC\",\"crv\":\"P-256\"}",
                messageVersion: "messageVersion"
            )
            mockService.onPerformFingerprint = { $1(.success(authenticationRequestParameters)) }

            let coreActionHandler = ThreeDS2PlusDACoreActionHandler(
                context: Dummy.context,
                service: mockService,
                presenter: ThreeDS2PlusDAScreenPresenter(
                    style: .init(),
                    localizedParameters: nil,
                    context: Dummy.context
                ),
                theme: .default,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: ""),
                delegatedAuthenticationService: authenticationServiceMock,
                deviceSupportCheckerService: DeviceSupportCheckerMock(isDeviceSupported: true)
            )
            coreActionHandler.delegatedAuthenticationState.attemptRegistration = true
            
            let compactActionHandler = ThreeDS2CompactActionHandler(
                context: Dummy.context,
                fingerprintSubmitter: AnyThreeDS2FingerprintSubmitterMock(),
                theme: .default,
                service: mockService,
                coreActionHandler: coreActionHandler,
                delegatedAuthenticationConfiguration: .init(relyingPartyIdentifier: "")
            )
            mockService.onPerformChallenge = { $1(.success(AnyChallengeResultMock(sdkTransactionIdentifier: "sdkTxId", transactionStatus: "Y"))) }
            let sut = AuthenticationComponent(
                context: Dummy.context,
                threeDS2CompactFlowHandler: compactActionHandler,
                redirectComponent: redirectComponent
            )
            sut.presentationDelegate = presentationDelegateMock
            // Verify if we get a challengeResult.
            let delegateExpectation = expectation(description: "Expect delegate didProvide(_:from:) function to be called.")
            delegate.onDidProvide = { data, component in
                XCTAssertTrue(component === sut)
                XCTAssertNil(data.paymentData)

                guard let threeDSResult = data.details as? ThreeDSResult else {
                    XCTFail("Expected ThreeDSResult but got \(type(of: data.details))")
                    return
                }
                XCTAssertEqual(threeDSResult.payload, "eyJhdXRob3Jpc2F0aW9uVG9rZW4iOiJhdXRoVG9rZW4iLCJ0cmFuc1N0YXR1cyI6IlkifQ==")

                delegateExpectation.fulfill()
            }
    
            // Verify if the UI is displayed & simulate the tap of the first button which is approve.
            let registrationViewExpectation = expectation(description: "Registration view controller should be shown.")
            let registrationErrorViewExpectation = expectation(description: "Registration error view controller should be shown.")

            presentationDelegateMock.doPresent = { component in
                if let registrationViewController = component.viewController as? DARegistrationViewController {
                    self.verifyRegistrationView(viewController: registrationViewController)
                    XCTAssertNotNil(registrationViewController)
                    registrationViewExpectation.fulfill()
                    registrationViewController.firstButtonTapped()
                } else if let errorViewController = component.viewController as? DAErrorViewController {
                    XCTAssertNotNil(errorViewController)
                    self.verifyRegistrationErrorView(controller: errorViewController)
                    registrationErrorViewExpectation.fulfill()
                    errorViewController.firstButtonTapped()
                }
            }

            sut.delegate = delegate
    
            // execute a challenge - as the registration flow is triggered only during a challenge flow.
            sut.handle(ThreeDS2Action.challenge(ThreeDS2ChallengeAction(challengeToken: TestData.challengeToken, authorisationToken: "authToken", paymentData: "paymentData")))

            wait(
                for: [registrationViewExpectation, onRegisterExpectation, registrationErrorViewExpectation, delegateExpectation],
                timeout: 2,
                enforceOrder: true
            )
        }

        func verifyApprovalView(viewController: DAApprovalViewController?) {
            guard let viewController else { XCTFail("No DARegistrationViewController passed"); return }
            let image: UIImageView? = viewController.view.findView(by: "image")
            XCTAssertNotNil(image)
            let titleLabel: UILabel? = viewController.view.findView(by: "titleLabel")
            XCTAssertNotNil(titleLabel)
            XCTAssertEqual(titleLabel?.text, "Approve transaction")

            let descriptionLabel: UILabel? = viewController.view.findView(by: "descriptionLabel")
            XCTAssertNotNil(descriptionLabel)
            XCTAssertEqual(descriptionLabel?.text, "Approve this transaction to complete your purchase.")

            let firstButton: FormButton? = viewController.view.findView(by: "primaryButton")
            XCTAssertNotNil(firstButton)
            XCTAssertEqual(firstButton?.title, "Approve transaction")

            let secondButton: FormButton? = viewController.view.findView(by: "secondaryButton")
            XCTAssertNotNil(secondButton)
            XCTAssertEqual(secondButton?.title, "Other options")
        }
        
        func verifyApprovalErrorView(controller: DAErrorViewController) {
            let image: UIImageView? = controller.view.findView(by: "image")
            XCTAssertNotNil(image)
            let titleLabel: UILabel? = controller.view.findView(by: "titleLabel")
            XCTAssertNotNil(titleLabel)
            XCTAssertEqual(titleLabel?.text, "Authenticating…")

            let descriptionLabel: UILabel? = controller.view.findView(by: "descriptionLabel")
            XCTAssertNotNil(descriptionLabel)
            XCTAssertEqual(descriptionLabel?.text, "Couldn’t approve payment with Secure Checkout")

            let troubleshootingTitle: UILabel? = controller.view.findView(by: "troubleshootingTitle")
            XCTAssertNotNil(troubleshootingTitle)
            XCTAssertEqual(troubleshootingTitle?.text, "Troubleshooting")

            let troubleshootingDescriptionLabel: UILabel? = controller.view.findView(by: "troubleshootingDescription")
            XCTAssertNotNil(troubleshootingDescriptionLabel)
            XCTAssertEqual(troubleshootingDescriptionLabel?.text, "Ongoing payment issues may be resolved by resetting your Secure Checkout details.")

            let troubleshootingButton: FormButton? = controller.view.findView(by: "troubleshootingButton")
            XCTAssertNotNil(troubleshootingButton)
            XCTAssertEqual(troubleshootingButton?.title, "Reset Secure Checkout")

            let firstButton: FormButton? = controller.view.findView(by: "primaryButton")
            XCTAssertNotNil(firstButton)
            XCTAssertEqual(firstButton?.title, "Approve differently")
        }
    
        func verifyTroubleshootingAlert(controller: UIAlertController) {
            XCTAssertEqual(controller.actions.count, 2)
            XCTAssertEqual(controller.title, "Reset Secure Checkout")
            XCTAssertEqual(controller.message, "You will be redirected to complete this payment in a different way.")
            XCTAssertEqual(controller.actions.first?.title, "Cancel")
            XCTAssertEqual(controller.actions.last?.title, "Reset")
        }

        func verifyRegistrationView(viewController: DARegistrationViewController?) {
            guard let viewController else { XCTFail("No DAApprovalViewController passed"); return }
            let image: UIImageView? = viewController.view.findView(by: "image")
            XCTAssertNotNil(image)
            let titleLabel: UILabel? = viewController.view.findView(by: "titleLabel")
            XCTAssertNotNil(titleLabel)
            XCTAssertEqual(titleLabel?.text, "Secure checkout")

            let descriptionLabel: UILabel? = viewController.view.findView(by: "descriptionLabel")
            XCTAssertNotNil(descriptionLabel)
            XCTAssertEqual(descriptionLabel?.text, "Check out faster next time with this card")

            let firstButton: FormButton? = viewController.view.findView(by: "primaryButton")
            XCTAssertNotNil(firstButton)
            XCTAssertEqual(firstButton?.title, "Use secure checkout")
            let secondButton: FormButton? = viewController.view.findView(by: "secondaryButton")
            XCTAssertNotNil(secondButton)
            XCTAssertEqual(secondButton?.title, "Not now")
        }
    
        func verifyRegistrationErrorView(controller: DAErrorViewController) {
            let image: UIImageView? = controller.view.findView(by: "image")
            XCTAssertNotNil(image)
            let titleLabel: UILabel? = controller.view.findView(by: "titleLabel")
            XCTAssertNotNil(titleLabel)
            XCTAssertEqual(titleLabel?.text, "Let’s try next time!")

            let descriptionLabel: UILabel? = controller.view.findView(by: "descriptionLabel")
            XCTAssertNotNil(descriptionLabel)
            XCTAssertEqual(descriptionLabel?.text, "Your payment has still been authenticated successfully but the Secure Checkout service was unavailable.")

            let firstButton: FormButton? = controller.view.findView(by: "primaryButton")
            XCTAssertNotNil(firstButton)
            XCTAssertEqual(firstButton?.title, "Finish")

        }

    #endif
}
