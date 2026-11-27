//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
import XCTest

class ActionTests: XCTestCase {
    
    func testRedirectActionDecoding() throws {
        let json =
            """
            {
                "type": "redirect",
                "url": "https://example.org/",
                "paymentData": "example_data"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: try XCTUnwrap(json.data(using: .utf8)))
        
        var redirectAction: RedirectAction?
        if case let .redirect(redirect)? = action?.kind {
            redirectAction = redirect
        }
        
        XCTAssertNotNil(redirectAction)
        XCTAssertEqual(redirectAction?.url.absoluteString, "https://example.org/")
        XCTAssertEqual(redirectAction?.paymentData, "example_data")
    }
    
    func testPixQRCodeActionDecoding() throws {
        let json =
            """
            {
                "type": "qrCode",
                "qrCodeData": "example_data",
                "paymentData": "example_data",
                "paymentMethodType": "pix"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: try XCTUnwrap(json.data(using: .utf8)))
        
        var qrCodeAction: QRCodeAction?
        if case let .qrCode(qrCode)? = action?.kind {
            qrCodeAction = qrCode
        }

        XCTAssertNotNil(qrCodeAction)
        XCTAssertEqual(qrCodeAction?.paymentData, "example_data")
        XCTAssertEqual(qrCodeAction?.qrCodePaymentMethodType, .pix)
        XCTAssertEqual(qrCodeAction?.paymentMethodType, .pix)
    }

    func testQRCodeActionDecoding() throws {
        let json =
            """
            {
                "type": "qrCode",
                "qrCodeData": "example_data",
                "paymentData": "example_data",
                "paymentMethodType": "promptpay"
            }
            """

        let action = try? JSONDecoder().decode(Action.self, from: try XCTUnwrap(json.data(using: .utf8)))

        var qrCodeAction: QRCodeAction?
        if case let .qrCode(qrCode)? = action?.kind {
            qrCodeAction = qrCode
        }

        XCTAssertNotNil(qrCodeAction)
        XCTAssertEqual(qrCodeAction?.paymentData, "example_data")
        XCTAssertEqual(qrCodeAction?.qrCodePaymentMethodType, .promptPay)
        XCTAssertEqual(qrCodeAction?.paymentMethodType, .promptPay)
    }

    func testQRCodeToRedirectActionDecoding() throws {
        let json =
            """
            {
                "type": "qrCode",
                "url": "https://example.org/",
                "paymentData": "example_data",
                "paymentMethodType": "bcmc_mobile"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: try XCTUnwrap(json.data(using: .utf8)))
        
        var qrToRedirectAction: RedirectAction?
        if case let .redirect(redirect)? = action?.kind {
            qrToRedirectAction = redirect
        }
        
        XCTAssertNotNil(qrToRedirectAction)
        XCTAssertEqual(qrToRedirectAction?.url.absoluteString, "https://example.org/")
        XCTAssertEqual(qrToRedirectAction?.paymentData, "example_data")
    }
    
    func testUPIQRCodeActionDecoding() throws {
        let json =
            """
            {
                "type": "qrCode",
                "qrCodeData": "example_data",
                "paymentData": "example_data",
                "paymentMethodType": "upi_qr"
            }
            """

        let action = try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))

        guard case let .qrCode(qrCodeAction) = action.kind else {
            return XCTFail("Expected a QR code action, got \(action)")
        }
        XCTAssertEqual(qrCodeAction.qrCodePaymentMethodType, .upiQR)
        XCTAssertEqual(qrCodeAction.paymentMethodType, .upiQR)
    }

    func testQRCodeActionDecodingMapsEveryQRCodePaymentMethodType() throws {
        let expectedTypes: [String: PaymentMethodType] = [
            "pix": .pix,
            "promptpay": .promptPay,
            "duitnow": .duitNow,
            "paynow": .payNow,
            "upi_qr": .upiQR
        ]

        for (rawValue, expectedType) in expectedTypes {
            let json =
                """
                {
                    "type": "qrCode",
                    "qrCodeData": "example_data",
                    "paymentData": "example_data",
                    "paymentMethodType": "\(rawValue)"
                }
                """

            let action = try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))

            guard case let .qrCode(qrCodeAction) = action.kind else {
                return XCTFail("Expected a QR code action for \(rawValue), got \(action)")
            }
            XCTAssertEqual(qrCodeAction.paymentMethodType, expectedType)
        }
    }

    func testAwaitActionDecoding() throws {
        let json =
            """
            {
                "type": "await",
                "paymentData": "example_data",
                "paymentMethodType": "mbway"
            }
            """

        let action = try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))

        guard case let .await(awaitAction) = action.kind else {
            return XCTFail("Expected an await action, got \(action)")
        }
        XCTAssertEqual(awaitAction.paymentData, "example_data")
        XCTAssertEqual(awaitAction.paymentMethodType, .mbWay)
    }

    func testAwaitActionDecodingWithUnlistedPaymentMethod() throws {
        let json =
            """
            {
                "type": "await",
                "paymentData": "example_data",
                "paymentMethodType": "some_future_method"
            }
            """

        let action = try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))

        guard case let .await(awaitAction) = action.kind else {
            return XCTFail("Expected an await action, got \(action)")
        }
        XCTAssertEqual(awaitAction.paymentMethodType, PaymentMethodType(rawValue: "some_future_method"))
    }

    func testRedirectableAwaitActionDecoding() throws {
        let json =
            """
            {
                "type": "await",
                "paymentData": "example_data",
                "paymentMethodType": "upi_intent",
                "url": "upi://pay"
            }
            """

        let action = try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))

        guard case let .redirectableAwait(awaitAction) = action.kind else {
            return XCTFail("Expected a redirectable await action, got \(action)")
        }
        XCTAssertEqual(awaitAction.paymentMethodType, .upiIntent)
        XCTAssertEqual(awaitAction.url.absoluteString, "upi://pay")
    }

    func testDocumentActionDecoding() throws {
        let json =
            """
            {
                "type": "voucher",
                "paymentMethodType": "directdebit_GB",
                "url": "https://example.org/mandate.pdf"
            }
            """

        let action = try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))

        guard case let .document(documentAction) = action.kind else {
            return XCTFail("Expected a document action, got \(action)")
        }
        XCTAssertEqual(documentAction.paymentMethodType, .bacsDirectDebit)
        XCTAssertEqual(documentAction.downloadUrl.absoluteString, "https://example.org/mandate.pdf")
    }

    func testVoucherActionDecodingWithUnsupportedPaymentMethod() throws {
        let json =
            """
            {
                "type": "voucher",
                "paymentMethodType": "some_future_voucher",
                "reference": "reference"
            }
            """

        XCTAssertThrowsError(try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8))))
    }

    func test3DS2FingerprintActionDecoding() throws {
        let json =
            """
            {
                "type": "threeDS2",
                "subtype": "fingerprint",
                "token": "example_token",
                "paymentData": "example_data"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: try XCTUnwrap(json.data(using: .utf8)))
        
        var fingerprintAction: ThreeDS2FingerprintAction?
        if case let .threeDS2(.fingerprint(fingerprint))? = action?.kind {
            fingerprintAction = fingerprint
        }
        
        XCTAssertNotNil(fingerprintAction)
        XCTAssertEqual(fingerprintAction?.fingerprintToken, "example_token")
        XCTAssertEqual(fingerprintAction?.paymentData, "example_data")
    }
    
    func test3DS2ChallengeActionDecoding() throws {
        let json =
            """
            {
                "type": "threeDS2",
                "subtype": "challenge",
                "token": "example_token",
                "paymentData": "example_data"
            }
            """
        
        let action = try? JSONDecoder().decode(Action.self, from: try XCTUnwrap(json.data(using: .utf8)))
        
        var challengeAction: ThreeDS2ChallengeAction?
        if case let .threeDS2(.challenge(challenge))? = action?.kind {
            challengeAction = challenge
        }
        
        XCTAssertNotNil(challengeAction)
        XCTAssertEqual(challengeAction?.challengeToken, "example_token")
        XCTAssertEqual(challengeAction?.paymentData, "example_data")
    }
    
    func testActionTypeDecodesKnownRawValues() throws {
        let json = "[\"redirect\", \"nativeRedirect\", \"threeDS2\", \"sdk\", \"qrCode\", \"await\", \"voucher\"]"
        let data = try XCTUnwrap(json.data(using: .utf8))
        
        let types = try JSONDecoder().decode([ActionType].self, from: data)
        
        XCTAssertEqual(types, [.redirect, .nativeRedirect, .threeDS2, .sdk, .qrCode, .await, .voucher])
    }
    
    func testActionTypeDecodesUnknownRawValue() throws {
        let json = "[\"someFutureType\"]"
        let data = try XCTUnwrap(json.data(using: .utf8))
        
        let types = try JSONDecoder().decode([ActionType].self, from: data)
        
        XCTAssertEqual(types, [ActionType(rawValue: "someFutureType")])
    }
    
    func testInvalidActionDecoding() throws {
        let json = "{ \"type\": \"InvalidType\" }"
        let data = try XCTUnwrap(json.data(using: .utf8))
        
        XCTAssertThrowsError(try JSONDecoder().decode(Action.self, from: data))
    }

    // MARK: - Public properties

    func testActionDecodingExposesTypePaymentDataAndPaymentMethodType() throws {
        let action = try decodeAction(
            """
            {
                "type": "qrCode",
                "qrCodeData": "example_data",
                "paymentData": "example_data",
                "paymentMethodType": "pix"
            }
            """
        )

        XCTAssertEqual(action.type, .qrCode)
        XCTAssertEqual(action.paymentData, "example_data")
        XCTAssertEqual(action.paymentMethodType, .pix)
    }

    func testActionDecodingWithNativeRedirectKeepsNativeRedirectType() throws {
        let action = try decodeAction(
            """
            {
                "type": "nativeRedirect",
                "url": "https://example.org/",
                "paymentData": "example_data",
                "paymentMethodType": "ideal",
                "nativeRedirectData": "native_data"
            }
            """
        )

        XCTAssertEqual(action.type, .nativeRedirect)
        XCTAssertEqual(action.paymentData, "example_data")
        XCTAssertEqual(action.paymentMethodType, .ideal)
        guard case .redirect = action.kind else {
            return XCTFail("Expected a redirect action, got \(action.kind)")
        }
    }

    func testActionDecodingWithoutPaymentMethodTypeHasNilPaymentMethodType() throws {
        let action = try decodeAction(
            """
            {
                "type": "threeDS2",
                "subtype": "fingerprint",
                "token": "example_token",
                "paymentData": "example_data"
            }
            """
        )

        XCTAssertEqual(action.type, .threeDS2)
        XCTAssertEqual(action.paymentData, "example_data")
        XCTAssertNil(action.paymentMethodType)
    }

    func testActionDecodingWithoutPaymentDataHasNilPaymentData() throws {
        let action = try decodeAction(
            """
            {
                "type": "voucher",
                "paymentMethodType": "directdebit_GB",
                "url": "https://example.org/mandate.pdf"
            }
            """
        )

        XCTAssertEqual(action.type, .voucher)
        XCTAssertNil(action.paymentData)
        XCTAssertEqual(action.paymentMethodType, .bacsDirectDebit)
    }

    func testQRCodeToRedirectActionDecodingKeepsQRCodeType() throws {
        let action = try decodeAction(
            """
            {
                "type": "qrCode",
                "url": "https://example.org/",
                "paymentData": "example_data",
                "paymentMethodType": "bcmc_mobile"
            }
            """
        )

        XCTAssertEqual(action.type, .qrCode)
        XCTAssertEqual(action.paymentData, "example_data")
        XCTAssertEqual(action.paymentMethodType, .bcmcMobile)
        guard case .redirect = action.kind else {
            return XCTFail("Expected a redirect action, got \(action.kind)")
        }
    }

    private func decodeAction(_ json: String) throws -> Action {
        try JSONDecoder().decode(Action.self, from: XCTUnwrap(json.data(using: .utf8)))
    }

}
