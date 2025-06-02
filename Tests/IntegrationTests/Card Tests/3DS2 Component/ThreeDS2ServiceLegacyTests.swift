//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Adyen3DS2
@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

final class ThreeDS2ServiceLegacyTests: XCTestCase {
    func testServiceFingerprintingSuccessfully() {
        let serviceMock = AnyADYServiceMock()
        serviceMock.authenticationRequestParameters = AuthenticationRequestParametersMock(
            deviceInformation: "DeviceInfor",
            sdkApplicationIdentifier: "",
            sdkTransactionIdentifier: "",
            sdkReferenceNumber: "",
            sdkEphemeralPublicKey: "",
            messageVersion: ""
        )
        let sut = ThreeDSServiceLegacy(service: serviceMock)
        let fingerprintParameters = FingerprintServiceParameters(
            directoryServerIdentifier: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: "",
            deviceExcludedParameters: nil,
            appearanceConfiguration: ADYAppearanceConfiguration(),
            threeDSMessageVersion: ""
        )
        let expectationFingerprintCreated = expectation(description: "expectationFingerprintCreated")
        sut.performFingerprint(
            parameters: fingerprintParameters
        ) { result in
            switch result {
            case let .success(success):
                XCTAssertEqual(success.deviceInformation, "DeviceInfor")
            case let .failure(failure):
                XCTFail("performFingerprint - Should NOT fail - \(failure)")
            }
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
    }
    
    func testServiceFingerprintingWithFailure() {
        let serviceMock = AnyADYServiceMock()
        serviceMock.onTransaction = { messageVersion in
            XCTAssertEqual(messageVersion, "threeDSMessageVersion")
            throw NSError(domain: "", code: 1)
        }
        let sut = ThreeDSServiceLegacy(service: serviceMock)
        let fingerprintParameters = FingerprintServiceParameters(
            directoryServerIdentifier: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: "",
            deviceExcludedParameters: nil,
            appearanceConfiguration: ADYAppearanceConfiguration(),
            threeDSMessageVersion: "threeDSMessageVersion"
        )
        let expectationFingerprintCreated = expectation(description: "expectationFingerprintCreated")
        sut.performFingerprint(
            parameters: fingerprintParameters
        ) { result in
            switch result {
            case .success:
                XCTFail("performFingerprint - Should NOT succeed ")
            case let .failure(failure):
                switch failure {
                case let .fingerprintingError(errorPayload: payload):
                    XCTAssertFalse(payload.isEmpty)
                case .messageVersionCreationError,
                     .serviceParameterCreationError,
                     .transactionCreationError:
                    XCTFail("Unexpected errors")
                }
            }
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
    }
    
    func testPerformChallenge() {
        let serviceMock = AnyADYServiceMock()
        let transactionMock = AnyADYTransactionMock(
            parameters: AuthenticationRequestParametersMock(
                deviceInformation: "DeviceInfor",
                sdkApplicationIdentifier: "",
                sdkTransactionIdentifier: "",
                sdkReferenceNumber: "",
                sdkEphemeralPublicKey: "",
                messageVersion: ""
            )
        )
        transactionMock.onPerformChallenge = { parameters, completion in
            completion(AnyChallengeResultMock(sdkTransactionIdentifier: "", transactionStatus: "Y"), nil)
        }
        
        serviceMock.mockedTransaction = transactionMock
        
        let sut = ThreeDSServiceLegacy(service: serviceMock)
        let fingerprintParameters = FingerprintServiceParameters(
            directoryServerIdentifier: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: "",
            deviceExcludedParameters: nil,
            appearanceConfiguration: ADYAppearanceConfiguration(),
            threeDSMessageVersion: ""
        )
        let challengeToken = ThreeDS2Component.ChallengeToken(acsReferenceNumber: "", acsSignedContent: "", acsTransactionIdentifier: "", serverTransactionIdentifier: "", threeDSRequestorAppURL: nil, delegatedAuthenticationSDKInput: nil, paymentInfo: nil)
        let expectationFingerprintCreated = expectation(description: "expectationFingerprintCreated")
        sut.performFingerprint(
            parameters: fingerprintParameters
        ) { result in
            switch result {
            case .success:
                sut.performChallenge(with: .init(challengeToken: challengeToken, threeDSRequestorAppURL: nil)) { challengeResult in
                    switch challengeResult {
                    case let .success(result):
                        XCTAssertEqual(result.transactionStatus, "Y")
                    case let .failure(error):
                        XCTFail("performChallenge - Should NOT fail - \(error)")
                    }
                }
            case let .failure(failure):
                XCTFail("performFingerprint - Should NOT fail - \(failure)")
            }
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
    }
    
    func testPerformChallengeWhenErroringOut() {
        let serviceMock = AnyADYServiceMock()
        let transactionMock = AnyADYTransactionMock(
            parameters: AuthenticationRequestParametersMock(
                deviceInformation: "DeviceInfor",
                sdkApplicationIdentifier: "",
                sdkTransactionIdentifier: "",
                sdkReferenceNumber: "",
                sdkEphemeralPublicKey: "",
                messageVersion: ""
            )
        )
        transactionMock.onPerformChallenge = { parameters, completion in
            completion(nil, nil)
        }
        
        serviceMock.mockedTransaction = transactionMock
        
        let sut = ThreeDSServiceLegacy(service: serviceMock)
        let fingerprintParameters = FingerprintServiceParameters(
            directoryServerIdentifier: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: "",
            deviceExcludedParameters: nil,
            appearanceConfiguration: ADYAppearanceConfiguration(),
            threeDSMessageVersion: ""
        )
        let challengeToken = ThreeDS2Component.ChallengeToken(acsReferenceNumber: "", acsSignedContent: "", acsTransactionIdentifier: "", serverTransactionIdentifier: "", threeDSRequestorAppURL: nil, delegatedAuthenticationSDKInput: nil, paymentInfo: nil)
        let expectationFingerprintCreated = expectation(description: "expectationFingerprintCreated")
        sut.performFingerprint(
            parameters: fingerprintParameters
        ) { result in
            switch result {
            case .success:
                sut.performChallenge(with: .init(challengeToken: challengeToken, threeDSRequestorAppURL: nil)) { challengeResult in
                    switch challengeResult {
                    case let .success:
                        XCTFail("performChallenge - Should NOT succeed")
                    case let .failure(error):
                        switch error {
                        case .errorAndResultAreNil: break
                        default:
                            XCTFail("performChallenge - invalid error sent back expected -[errorAndResultAreNil]  - \(error)")
                        }
                    }
                }
            case let .failure(failure):
                XCTFail("performFingerprint - Should NOT fail - \(failure)")
            }
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
    }
    
    func testPerformChallengeWhenErroringOutWithChallengeError() {
        let serviceMock = AnyADYServiceMock()
        let transactionMock = AnyADYTransactionMock(
            parameters: AuthenticationRequestParametersMock(
                deviceInformation: "DeviceInfor",
                sdkApplicationIdentifier: "",
                sdkTransactionIdentifier: "",
                sdkReferenceNumber: "",
                sdkEphemeralPublicKey: "",
                messageVersion: ""
            )
        )
        transactionMock.onPerformChallenge = { parameters, completion in
            completion(nil, NSError(domain: "", code: 1))
        }
        
        serviceMock.mockedTransaction = transactionMock
        
        let sut = ThreeDSServiceLegacy(service: serviceMock)
        let fingerprintParameters = FingerprintServiceParameters(
            directoryServerIdentifier: "",
            directoryServerPublicKey: "",
            directoryServerRootCertificates: "",
            deviceExcludedParameters: nil,
            appearanceConfiguration: ADYAppearanceConfiguration(),
            threeDSMessageVersion: ""
        )
        let challengeToken = ThreeDS2Component.ChallengeToken(acsReferenceNumber: "", acsSignedContent: "", acsTransactionIdentifier: "", serverTransactionIdentifier: "", threeDSRequestorAppURL: nil, delegatedAuthenticationSDKInput: nil, paymentInfo: nil)
        let expectationFingerprintCreated = expectation(description: "expectationFingerprintCreated")
        sut.performFingerprint(
            parameters: fingerprintParameters
        ) { result in
            switch result {
            case .success:
                sut.performChallenge(with: .init(challengeToken: challengeToken, threeDSRequestorAppURL: nil)) { challengeResult in
                    switch challengeResult {
                    case .success:
                        XCTFail("performChallenge - Should NOT succeed")
                    case let .failure(error):
                        switch error {
                        case .challengeError: break
                        default:
                            XCTFail("performChallenge - invalid error sent back expected -[challengeError]  - \(error)")
                        }
                    }
                }
            case let .failure(failure):
                XCTFail("performFingerprint - Should NOT fail - \(failure)")
            }
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
    }
    
}
