//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import class Adyen3DS2.ADYAppearanceConfiguration
import Adyen3DS2_Swift
@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

@MainActor
final class ThreeDSServiceTests: XCTestCase {
    
    func testFingerprintServiceCreationError() throws {
        let sut = makeSUT(
            onCreateTransactionResult: .failure(NSError.mock)
        )
        let expectedError = try expectErrorOnFingerprint(
            service: sut,
            parameters: .mockWithEmptyValues
        )
        switch expectedError {
        case .serviceParameterCreationError:
            break
        default:
            XCTFail("Unexpected error received.")
        }
    }
    
    func testFingerprintMessageVersionCreationError() throws {
        let sut = makeSUT(
            onCreateTransactionResult: .failure(NSError.mock)
        )
        let expectedError = try expectErrorOnFingerprint(
            service: sut,
            parameters: .mockWithInvalidMessageVersion
        )
        
        switch expectedError {
        case .messageVersionCreationError:
            break
        default:
            XCTFail("Unexpected error received.")
        }
    }

    func testFingerprintTransactionCreationError() throws {
        let sut = makeSUT(
            onCreateTransactionResult: .failure(NSError.mock)
        )
        let expectedError = try expectErrorOnFingerprint(
            service: sut,
            parameters: .mockValid
        )
        switch expectedError {
        case .transactionCreationError:
            break
        default:
            XCTFail("Unexpected error received.")
        }
    }
    
    func testFingerprintSuccess() throws {
        let sut = makeSUT(
            onCreateTransactionResult: .success(MockTransactionRepresentable.mock)
        )

        try expectSuccessOnFingerprint(
            service: sut,
            parameters: .mockValid
        )
    }
    
    func testChallengeSuccess() throws {
        let sut = makeSUT(
            onPerformChallengeResult: .success(AnyChallengeResultMock.mock),
            presentingControllerHandler: { UIViewController() }
        )

        try expectSuccessOnFingerprint(
            service: sut,
            parameters: .mockValid
        )
        try expectChallengeSuccess(service: sut)
    }
    
    func testChallengeWithoutPerformingFingerprinting() throws {
        let sut = makeSUT(
            onPerformChallengeResult: .success(AnyChallengeResultMock.mock),
            presentingControllerHandler: { UIViewController() }
        )
        let expectedError = try expectErrorOnPerformChallenge(service: sut)
        switch expectedError {
        case ThreeDSServiceChallengeError.transactionNotInitialized:
            break
        default:
            XCTFail("Unexpected error thrown.")
        }
    }
    
    func testChallengeWithoutPresentingController() throws {
        let sut = makeSUT(
            onPerformChallengeResult: .success(AnyChallengeResultMock.mock),
            presentingControllerHandler: {
                throw UnknownError.topViewControllerNotDetermined
            }
        )

        try expectSuccessOnFingerprint(
            service: sut,
            parameters: .mockValid
        )
        let expectedError = try expectErrorOnPerformChallenge(service: sut)
        switch expectedError {
        case .topViewControllerCouldNotBeDetermined:
            break
        default:
            XCTFail("Unexpected error returned.")
        }
    }

    func testChallengeWithFailureOnChallenge() throws {
        let sut = makeSUT(
            onPerformChallengeResult: .failure(NSError.mock),
            presentingControllerHandler: { UIViewController() }
        )
        
        try expectSuccessOnFingerprint(
            service: sut,
            parameters: .mockValid
        )
        let expectedError = try expectErrorOnPerformChallenge(service: sut)
        switch expectedError {
        case .challengeError:
            break
        default:
            XCTFail("Unexpected error returned.")
        }
    }
    
    // MARK: - Expect helpers
    
    private func expectErrorOnFingerprint(
        service: ThreeDSService,
        parameters: FingerprintServiceParameters
    ) throws -> ThreeDSServiceFingerprintError {
        var error: ThreeDSServiceFingerprintError?
        let expectationFingerprintCreated = expectation(description: "Fingerprint created")
        service.performFingerprint(
            parameters: parameters
        ) { result in
            XCTAssertNil(try? result.get())
            error = result.failure
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
        return try XCTUnwrap(error)
    }
    
    private func expectSuccessOnFingerprint(
        service: ThreeDSService,
        parameters: FingerprintServiceParameters
    ) throws {
        let expectationFingerprintCreated = expectation(description: "Fingerprint created")
        service.performFingerprint(
            parameters: parameters
        ) { result in
            XCTAssertNotNil(try? result.get())
            expectationFingerprintCreated.fulfill()
        }
        wait(for: [expectationFingerprintCreated], timeout: 0.1)
    }
    
    private func expectChallengeSuccess(service: ThreeDSService) throws {
        let expectationChallengeHandled = expectation(description: "Challenge handled")
        service.performChallenge(
            with: .mock
        ) { result in
            XCTAssertNotNil(try? result.get())
            expectationChallengeHandled.fulfill()
        }
        wait(for: [expectationChallengeHandled], timeout: 1)
    }
    
    private func expectErrorOnPerformChallenge(service: ThreeDSService) throws -> ThreeDSServiceChallengeError {
        var error: ThreeDSServiceChallengeError?
        let expectationChallengeHandled = expectation(description: "Challenge handled")
        service.performChallenge(
            with: .mock
        ) { result in
            XCTAssertNil(try? result.get())
            error = result.failure
            expectationChallengeHandled.fulfill()
        }
        wait(for: [expectationChallengeHandled], timeout: 1)
        return try XCTUnwrap(error)
    }

    // MARK: - SUT constructors
    
    private func makeSUT(
        onCreateTransactionResult: Result<TransactionRepresentable, any Error>
    ) -> ThreeDSService {
        let transactionProvider = MockTransactionProvider()
        transactionProvider.onCreateTransaction = { completion in
            completion(onCreateTransactionResult)
        }
        return ThreeDSService(transactionProvider: transactionProvider)
    }
    
    private func makeSUT(
        onPerformChallengeResult: Result<any AdyenActions.AnyChallengeResult, any Error>,
        presentingControllerHandler: @escaping () throws -> UIViewController
    ) -> ThreeDSService {

        let mockTransaction = MockTransactionRepresentable()

        let transactionProvider = MockTransactionProvider()
        transactionProvider.onCreateTransaction = { completion in
            completion(.success(mockTransaction))
        }

        mockTransaction.onFingerprintParameters = {
            AuthenticationRequestParametersMock.empty
        }
        mockTransaction.onPerformChallenge = {
            $2(onPerformChallengeResult)
        }
        return ThreeDSService(
            transactionProvider: transactionProvider,
            presentingControllerHandler: presentingControllerHandler
        )
    }
}

private extension MockTransactionRepresentable {
    static let mock: MockTransactionRepresentable = {
        let mockTransaction = MockTransactionRepresentable()
        mockTransaction.onFingerprintParameters = {
            AuthenticationRequestParametersMock.empty
        }
        return mockTransaction
    }()

}

private extension AuthenticationRequestParametersMock {
    static let empty = AuthenticationRequestParametersMock(
        deviceInformation: "",
        sdkApplicationIdentifier: "",
        sdkTransactionIdentifier: "",
        sdkReferenceNumber: "",
        sdkEphemeralPublicKey: "",
        messageVersion: ""
    )
}

private extension NSError {
    static let mock = NSError(domain: "", code: 100)
}

private extension AnyChallengeResultMock {
    static let mock = AnyChallengeResultMock(sdkTransactionIdentifier: "", transactionStatus: "")
}

private extension AdyenActions.ChallengeParameters {
    static let mock = AdyenActions.ChallengeParameters(
        challengeToken: .init(
            acsReferenceNumber: "",
            acsSignedContent: "",
            acsTransactionIdentifier: "",
            serverTransactionIdentifier: "",
            threeDSRequestorAppURL: nil,
            delegatedAuthenticationSDKInput: nil,
            paymentInfo: nil
        ),
        threeDSRequestorAppURL: nil
    )
}

private extension FingerprintServiceParameters {
    
    static let mockWithEmptyValues = FingerprintServiceParameters(
        directoryServerIdentifier: "",
        directoryServerPublicKey: "",
        directoryServerRootCertificates: "",
        deviceExcludedParameters: nil,
        appearanceConfiguration: ADYAppearanceConfiguration(),
        threeDSMessageVersion: "2.1.0"
    )
    
    static let mockWithInvalidMessageVersion = FingerprintServiceParameters(
        directoryServerIdentifier: "123",
        directoryServerPublicKey: publicKey,
        directoryServerRootCertificates: rootCertificates,
        deviceExcludedParameters: nil,
        appearanceConfiguration: ADYAppearanceConfiguration(),
        threeDSMessageVersion: "0.0.0"
    )
    
    static let mockValid = FingerprintServiceParameters(
        directoryServerIdentifier: "123",
        directoryServerPublicKey: publicKey,
        directoryServerRootCertificates: rootCertificates,
        deviceExcludedParameters: nil,
        appearanceConfiguration: ADYAppearanceConfiguration(),
        threeDSMessageVersion: "2.1.0"
    )
    
    private static let rootCertificates: String = "eyAiYWxnIjogIkVTNTEyIiwgIng1YyI6IFsgIk1JSUMxekNDQWptZ0F3SUJBZ0lDRUFBd0NnWUlLb1pJemowRUF3SXdnWVV4Q3pBSkJnTlZCQVlUQWs1TU1Rc3dDUVlEVlFRSURBSk9TREVTTUJBR0ExVUVCd3dKUVcxemRHVnlaR0Z0TVJNd0VRWURWUVFLREFwQlpIbGxiaUJPTGxZdU1Sc3dHUVlEVlFRTERCSkJaSGxsYmlCUWJHRjBabTl5YlNCUVMwa3hJekFoQmdOVkJBTU1Ha0ZrZVdWdUlGQnNZWFJtYjNKdElFVkRReUJTYjI5MElFTkJNQjRYRFRJeU1EUXdOakE0TVRneE1Wb1hEVEkzTURRd05UQTRNVGd4TVZvd2RERUxNQWtHQTFVRUJoTUNUa3d4Q3pBSkJnTlZCQWdNQWs1SU1STXdFUVlEVlFRS0RBcEJaSGxsYmlCT0xsWXVNUnN3R1FZRFZRUUxEQkpCWkhsbGJpQlFiR0YwWm05eWJTQlFTMGt4SmpBa0JnTlZCQU1NSFV4SlZrVXVNMFJUTWlCRlEwTWdTVzUwWlhKdFpXUnBZWFJsSUVOQk1JR2JNQkFHQnlxR1NNNDlBZ0VHQlN1QkJBQWpBNEdHQUFRQW5FYlE0UGVNUmQvSVNWS0lSWDR2cHU0MnhSMG9rNkVMcTc1cUFwMEgwMmFUNXllaG00MVFUZVdkRTJZNnBBaFBZVkVXc0hOU0ltQU8yL20ySGhGK3Q1NEJpY3haNS9Wdk00dnQvYnVjdzVBYXdzQ2lEWlgwUm0yMnpPTEoyRTVXK25QU1k4b3dsMzlEamw4Z2wyZ0FHME1EektxMXZPSCtsNm5od05rdExjQ3luc2VqWmpCa01CMEdBMVVkRGdRV0JCU2JJanhRTTlOMkdYMWdJVWIvdE8rTHlVUytUakFmQmdOVkhTTUVHREFXZ0JRdEpDWERwcVdGdFRPQkNRalo5eDQ2REJPS3BUQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQTRHQTFVZER3RUIvd1FFQXdJQmhqQUtCZ2dxaGtqT1BRUURBZ09CaXdBd2dZY0NRZ0ROU2tLSWNaYVB5Qks0Ui9pZ2MwOU5RYitJOTNyenQ2U21KdjJuOCs2SDFveWVBZURKeDR1QWU3U2tOWDFmZEVGcHZLVjhrMDAwTjBXV0FKVnMrUEZTa3dKQlpuYmhJSXh3YTlkajkwWFFoNzB5MTJZWnExcHNSTEg2K2xKeDByQXhNSEJNMGtqVk1hQ2JFRXcyY2RhaWI0UmFRbnp0TDRqMjZRY1MyNWlrcW85eklPbz0iIF0gfQo.eyAiY2VydGlmaWNhdGVzIjogWyAiTUlJRDhqQ0NBdG9DQ1FETm5YeWNWRUl3dXpBTkJna3Foa2lHOXcwQkFRc0ZBRENCdWpFTE1Ba0dBMVVFQmhNQ1Rrd3hGakFVQmdOVkJBZ01EVTV2YjNKa0xVaHZiR3hoYm1ReEVqQVFCZ05WQkFjTUNVRnRjM1JsY21SaGJURVRNQkVHQTFVRUNnd0tRV1I1Wlc0Z1RpNVdMakVSTUE4R0ExVUVDd3dJUTJobFkydHZkWFF4TlRBekJnTlZCQU1NTERORVV6SWdVMmx0ZFd4aGRHOXlJRlpKVTBFZ1JGTWdRMlZ5ZEdsbWFXTmhkR1VnUVhWMGFHOXlhWFI1TVNBd0hnWUpLb1pJaHZjTkFRa0JGaEZ6ZFhCd2IzSjBRR0ZrZVdWdUxtTnZiVEFlRncweE9EQTRNamN4TXpRd05UaGFGdzB5T0RBNE1qUXhNelF3TlRoYU1JRzZNUXN3Q1FZRFZRUUdFd0pPVERFV01CUUdBMVVFQ0F3TlRtOXZjbVF0U0c5c2JHRnVaREVTTUJBR0ExVUVCd3dKUVcxemRHVnlaR0Z0TVJNd0VRWURWUVFLREFwQlpIbGxiaUJPTGxZdU1SRXdEd1lEVlFRTERBaERhR1ZqYTI5MWRERTFNRE1HQTFVRUF3d3NNMFJUTWlCVGFXMTFiR0YwYjNJZ1ZrbFRRU0JFVXlCRFpYSjBhV1pwWTJGMFpTQkJkWFJvYjNKcGRIa3hJREFlQmdrcWhraUc5dzBCQ1FFV0VYTjFjSEJ2Y25SQVlXUjVaVzR1WTI5dE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBdXA3K2Z0d1dnR2RjYTYxcVZCYzFCdlRpNVk0M0J3aFozU2hKSWttR0l3Z1lQc0o5cHJPY1pVVmVHa0VoYzVHWHcvOVJMY2xZbWlpMlovTFBFeXk2VUljUHNFRmlkUnpXTDZkODRiZGI4VDVpNklBTHNIU2dPZmNQTzJEQ1lvTjVGK0gvdlVhcHdZR2pCNFkraXdNZlEyZXNMM1FEZEUrL285L1o0TnBmbzkrY2YxRHplcFNXVnhUeFJSa1NYMUcrUXZrQk0vcGx0NW01eCtMVVkwejZVNCt1UXFCUVlzaTBVUDVNbWI4RTZVd0cya2M4NnRzZXc0WUxxU2NYdFU5Zy9vOTlnOUVrbkVTWm9COFFtamdJMHNaUXJFM0tvNEEyL1lDZTI1SmdaNzFLYzdFLzlIS1FLM1YxdGlMcnp4aVNLMHE4YkVOM2phYjRzUUpXY3pSNU5RSURBUUFCTUEwR0NTcUdTSWIzRFFFQkN3VUFBNElCQVFBbThxT0RBTkIzUHArOThRZnVRVUVUWGUxTlJwSnZEb2N5c2RvSitzdDhHWmRiV2lua09wN2ZsWTRYcEZyMlpJcU5ITXlKc2Y3OUlBS2xCZW9TWDd4VGZqZ3IyOHdna1N5dDVQV2I3WkYzWFQwbmdXc3hyMmR0RjdSdUF4UThKYlRwUExkRVkxWjJyaEo1YXRKdDdFSllFNkFYSnpBcjVVSjd5bTBjWSs5Tk0zVkJqU3BjOWVMT04zVGtZWG9VdjJkbUt1MUh6THZiMW1EMGVIeXVFclFPcmJUKzFvRk1lL0toenYxN0xrWDhqN094U0ttUi9IL1QyeXFnbXpPeGdNMGxLemszV2lRT24xa1RXYW9YOENoUDZpU21Ka3J3SVV5WitWMVVJUENUbnRsUXpFUUpIOTZRNW5ZTlRMTjhqVmxwNW1uS0d0UkFYcmx1cnhMaTlZNkUiLCAiTUlJR0JUQ0NBKzJnQXdJQkFnSUpBS09naDhzdUVxZU9NQTBHQ1NxR1NJYjNEUUVCQ3dVQU1JR1lNUXN3Q1FZRFZRUUdFd0pPVERFV01CUUdBMVVFQ0F3TlRtOXZjbVF0U0c5c2JHRnVaREVTTUJBR0ExVUVCd3dKUVcxemRHVnlaR0Z0TVJFd0R3WURWUVFLREFoQlpIbGxiaUJPVmpFZ01CNEdBMVVFQ3d3WE0wUWdVMlZqZFhKbElESXVNQ0JUYVcxMWJHRjBiM0l4S0RBbUJnTlZCQU1NSHpORUlGTmxZM1Z5WlNBeUxqQWdVMmx0ZFd4aGRHOXlJRkp2YjNRZ1EwRXdIaGNOTVRrd05qQTJNRGt3TnpJeldoY05Namt3TmpBek1Ea3dOekl6V2pDQm1ERUxNQWtHQTFVRUJoTUNUa3d4RmpBVUJnTlZCQWdNRFU1dmIzSmtMVWh2Ykd4aGJtUXhFakFRQmdOVkJBY01DVUZ0YzNSbGNtUmhiVEVSTUE4R0ExVUVDZ3dJUVdSNVpXNGdUbFl4SURBZUJnTlZCQXNNRnpORUlGTmxZM1Z5WlNBeUxqQWdVMmx0ZFd4aGRHOXlNU2d3SmdZRFZRUUREQjh6UkNCVFpXTjFjbVVnTWk0d0lGTnBiWFZzWVhSdmNpQlNiMjkwSUVOQk1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBbTFtaFNERlhZSzB4RWp2LzRBWUtJSFdyeFIrbGhUZVpieG9mc0pCbkhiQ3llbWUxdzNYUHZVTGpUemt5dTd1VllFWlMyZEpYYkxwb1FzdUprcllDNU9LWEY3MkFXNnJzRzJxSkQ1UVhBdTdTaDJveXZ5SU13NmhBakNyZ2VVSW0wS2RuOUdQVVN3VmxIV1lwcmRMMnVaeEFDNlJBV3FFZ3hxaCtzaW81SURxK3RCL2o5YUR2YVBsWk5aVThhU1Znbk9MTkY5Q1ljYXAxWEhiTUNsdEgwVXcyTGdYeG9Pd0tUZUdReDJZVW5ENmo1MVgwbmg0OUpiWmUzY2FQckhzSEQyaHJ3RWZPSkUxaUp0cXFuUVpqZ0lQT2cyamNwL1lYUGtDcDZLUFlMZUZnOENCVUMzSElnY3YzMWJjYzI2VkpCOGZ3SjZhbHdobEJNSnkzSzNnTUowanhVd2VQWGVmQm5jaW85N0NNMnhvRFNKVGZYNXFJb2U0bVJGT2gwQTRTVnBJUFR1SWEzMGVsWWIzZ1QxeWQvbWZHMGNYOEpiYllySm9tYTB3MGRzUnlyZTIzRng4ZWpJZHQ1UzJoVWJCbmszUTJxTmVMNzQrWWU2eHljOWdqV2txOWpsNzd5RmdjajhNbWlSQUNIeVAzdFFUak5ZOW5Bdk5aM2RpN0NFVW5mZHE0NmpUbEVqMU4wQzU1THY5b2JWNEFFbi9WRnlKZkw1dmpqN2FITEQyb2hrTGFGQ0d6S2ZOQ3NCcFFCUkc0Um5qamxnWFNXdFhlaWJQN0dMRkhEYjlwTTlkejJKMitFUmtBNjNtUXZCV082U3BnK1NnZnVMYmFNbjh6alFOSFA4UDJ0WnZ3VU9YK3I0d2FNWUxYWDdjQ0hkV1lMWjQ0WkRvQTArQUFqQ0VDQXdFQUFhTlFNRTR3SFFZRFZSME9CQllFRkhlcXhCZTVSTUhFN2h5VVJHYnlKeHVLcmwyeU1COEdBMVVkSXdRWU1CYUFGSGVxeEJlNVJNSEU3aHlVUkdieUp4dUtybDJ5TUF3R0ExVWRFd1FGTUFNQkFmOHdEUVlKS29aSWh2Y05BUUVMQlFBRGdnSUJBRjlmdzJ3VXByV2F2K1lHTGxBUElLY0gvRFBDMG0weG5sVGNlN2ppVERDbXIraU44M2krRzY4NWpwa2ZZUmhNVE1tcCsxMjNhZisrVnpXQmx0YmNLZUkya1FVWWhYY1lrVGc2ZURrZkJ1UU5WVEpNVmlSY3g2V2c4akFQb044SlZnUmpmeThOcXM4YVQvSStKNWJJNlY5aEU0aklHU3A0QkdkcEZtYnN4bE1QanFtNDZmNlBDNUpReWY1TWhuRjArdnZsbGFpalh5dlVKKzI5Y1lQT3FTeldOQXZjdDRuV3VabGREa0w0dzdlNFNGUFViRjkyWDhYY1h3N2p0L1hkRzVYSHlpZ3hnNXFrSFZ2Q2RvUEx6OEhYcG5GRGNqblhmdmlyT01RaG9ObTZYRWZvM3VyT0lqTDRMc2JvRzA4c0xJYlh1WGF4RlVNcWNtN3J3Q0FQTURDcENLbmNGUHA4cG1VbktxaTlEeGZORXh4UnlaVDRnWW9qWGcrcUxCcjljQVN0b3lpVkJDdkY3a3JnazNPS1BRYmpGQ2krMEJTc3FQY3c0eTZhMWpQenAyZ0tsWlhCblRtYmxtVXNvSXliOHF0eFBXMklRNW1lTGZKWkRlS0RZcytSZWdvSWozbGJva0hkR3g1MisvMEdBRkpiVHlhb3J1MU1sSmpvYUhnVGxZQm5iRTQrYnU5MDI1TEVHc2VyMjhjLzBnV29aS2UyUnBiRlorZk1Bek16ZjlTTjdyQ0w5TzdxbjBMek1lNHBNQUpIMUZEQTE5QXdPYVlMcXdkaDg5eEF0TXhmU2g0WUhXQ0h6T1U3V2luYk9EWG90S0dqVVRFRit1WWI0VDFpdHNyLzk5cEJoYXMxQjhYMVpWR3pnejVINStPekVrU2NXVUJNSTJFazhzQXEiIF0gfQo.MIGGAkFj8tf2jAGZC_6lhVvAn1cSEIDvcR8fiqcTnSSOSXSF0oJvoBHh5YMuL0xKyoqEtd0M9uSY9cgnBgjSCjDRXHo5pQJBDgfRZA1YzAzjlmnj00BK4W6BWrWw01t5boejNuV0W1CMVwUWAv-dfIo6CGRBmRxXVTf-UniRon2WTzu2387mZOA"
    
    private static let publicKey: String = "eyJrdHkiOiJSU0EiLCJlIjoiQVFBQiIsIm4iOiI4VFBxZkFOWk4xSUEzcHFuMkdhUVZjZ1g4LUpWZ1Y0M2diWURtYmdTY0N5SkVSN3lPWEJqQmQyaTBEcVFBQWpVUVBXVUxZU1FsRFRKYm91bVB1aXVoeVMxUHN2NTM4UHBRRnEySkNaSERkaV85WThVZG9hbmlrU095c2NHQWtBVmJJWHA5cnVOSm1wTTBwZ0s5VGxJSWVHYlE3ZEJaR01OQVJLQXRKeTY3dVlvbVpXV0ZBbWpwM2d4SDVzNzdCR2xkaE9RUVlQTFdybDdyS0pLQlUwNm1tZlktUDNpazk5MmtPUTNEak02bHR2WmNvLThET2RCR0RKYmdWRGFmb29LUnVNd2NUTXhDdTRWYWpyNmQyZkppVXlqNUYzcVBrYng4WDl6a1c3UmlxVno2SU1qdE54NzZicmg3aU9Vd2JiWmoxYWF6VG1GQ2xEb0dyY2JxOV80NncifQ=="

}
