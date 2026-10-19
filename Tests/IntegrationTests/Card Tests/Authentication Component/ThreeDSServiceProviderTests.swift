//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@testable import AdyenActions
@testable import AdyenCard
import XCTest

final class ThreeDSServiceProviderTests: XCTestCase {
    private let authenticationRequestParameters = AuthenticationRequestParametersMock(
        deviceInformation: "device_info",
        sdkApplicationIdentifier: "sdkApplicationIdentifier",
        sdkTransactionIdentifier: "sdkTransactionIdentifier",
        sdkReferenceNumber: "sdkReferenceNumber",
        sdkEphemeralPublicKey: "{\"y\":\"zv0kz1SKfNvT3ql75L217de6ZszxfLA8LUKOIKe5Zf4\",\"x\":\"3b3mPfWhuOxwOWydLejS3DJEUPiMVFxtzGCV6906rfc\",\"kty\":\"EC\",\"crv\":\"P-256\"}",
        messageVersion: "messageVersion"
    )

    /// Expect during fingerprint that
    /// Service is created and fingerprint performed.
    func testPerformFingerprint() {
        let serviceMock = ThreeDSServiceableMock()
        serviceMock.onResetTransaction = {}
        let expectationFingerprintCreated = expectation(description: "fingeprint")

        serviceMock.onPerformFingerprint = {
            expectationFingerprintCreated.fulfill()
            $1(.success(self.authenticationRequestParameters))
        }
        let expectationServiceCreated = expectation(description: "service created")
        let sut = ThreeDSServiceProvider { _ in
            expectationServiceCreated.fulfill()
            return serviceMock
        }
        sut.performFingerprint(
            parameters: FingerprintServiceParameters.mock
        ) { result in
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Shouldn't fail")
            }
        }
        
        wait(
            for: [
                expectationServiceCreated,
                expectationFingerprintCreated
            ],
            timeout: 0.1,
            enforceOrder: true
        )
    }
    
    func testChallenge() {
        let serviceMock = ThreeDSServiceableMock()
        let expectationFingerprintCreated = expectation(description: "fingeprint")

        serviceMock.onPerformFingerprint = {
            expectationFingerprintCreated.fulfill()
            $1(.success(self.authenticationRequestParameters))
        }
        
        let expectationChallengeExecuted = expectation(description: "fingeprint")
        serviceMock.onPerformChallenge = {
            expectationChallengeExecuted.fulfill()
            $1(.success(AnyChallengeResultMock(sdkTransactionIdentifier: "", transactionStatus: "Y")))
        }

        let expectationResetTransaction = expectation(description: "Reset transaction")
        serviceMock.onResetTransaction = {
            expectationResetTransaction.fulfill()
        }
        
        let expectationServiceCreated = expectation(description: "service created")
        let sut = ThreeDSServiceProvider { _ in
            expectationServiceCreated.fulfill()
            return serviceMock
        }
        sut.performFingerprint(
            parameters: FingerprintServiceParameters.mock
        ) { result in
            switch result {
            case .success:
                sut.performChallenge(with: .mock) { result in
                    switch result {
                    case .success:
                        break
                    case .failure:
                        XCTFail("Should not fail")
                    }
                }
            case .failure:
                XCTFail("Shouldn't fail")
            }
        }
        
        wait(
            for: [
                expectationServiceCreated,
                expectationFingerprintCreated,
                expectationChallengeExecuted,
                expectationResetTransaction
            ],
            timeout: 0.1,
            enforceOrder: true
        )
    }
    
    func testPerformChallengeWithoutFingerprint() {
        let sut = ThreeDSServiceProvider { _ in
            ThreeDSServiceableMock()
        }
        sut.performChallenge(
            with: ChallengeParameters.mock
        ) { result in
            switch result {
            case .success:
                XCTFail("Shouldn't pass challenge")
            case let .failure(failure):
                XCTAssertEqual(failure, .transactionNotInitialized)
            }
        }
    }
}

private extension FingerprintServiceParameters {
    static let mock = FingerprintServiceParameters(
        directoryServerIdentifier: "",
        directoryServerPublicKey: "",
        directoryServerRootCertificates: "",
        deviceExcludedParameters: nil,
        theme: .default,
        threeDSMessageVersion: ""
    )
}

private extension ChallengeParameters {
    static let mock = ChallengeParameters(
        challengeToken: AuthenticationComponent.ChallengeToken(
            acsReferenceNumber: "",
            acsSignedContent: "",
            acsTransactionIdentifier: "",
            serverTransactionIdentifier: "",
            threeDSRequestorAppURL: nil,
            delegatedAuthenticationSDKInput: "",
            paymentInfo: nil
        ),
        threeDSRequestorAppURL: nil
    )
}
