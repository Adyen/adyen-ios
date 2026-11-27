//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Foundation

/// Builds actions in tests the way they would be decoded from a `/payments` response.
extension Action {

    static func redirect(_ action: RedirectAction) -> Action {
        Action(
            kind: .redirect(action),
            type: action.type == .nativeRedirect ? .nativeRedirect : .redirect,
            paymentData: action.paymentData,
            paymentMethodType: action.paymentMethodType.map(PaymentMethodType.init(rawValue:))
        )
    }

    static func sdk(_ action: SDKAction) -> Action {
        switch action {
        case let .weChatPay(weChatPayAction):
            Action(kind: .sdk(action), type: .sdk, paymentData: weChatPayAction.paymentData, paymentMethodType: .weChatPaySDK)
        case let .twint(twintAction):
            Action(kind: .sdk(action), type: .sdk, paymentData: twintAction.paymentData, paymentMethodType: twintAction.paymentMethodType)
        }
    }

    static func threeDS2(_ action: ThreeDS2Action) -> Action {
        switch action {
        case let .fingerprint(fingerprintAction):
            Action(kind: .threeDS2(action), type: .threeDS2, paymentData: fingerprintAction.paymentData)
        case let .challenge(challengeAction):
            Action(kind: .threeDS2(action), type: .threeDS2, paymentData: challengeAction.paymentData)
        }
    }

    static func await(_ action: AwaitAction) -> Action {
        Action(kind: .await(action), type: .await, paymentData: action.paymentData, paymentMethodType: action.paymentMethodType)
    }

    static func redirectableAwait(_ action: RedirectableAwaitAction) -> Action {
        Action(kind: .redirectableAwait(action), type: .await, paymentData: action.paymentData, paymentMethodType: action.paymentMethodType)
    }

    static func voucher(_ action: VoucherAction) -> Action {
        Action(kind: .voucher(action), type: .voucher, paymentMethodType: action.anyAction.paymentMethodType)
    }

    static func qrCode(_ action: QRCodeAction) -> Action {
        Action(kind: .qrCode(action), type: .qrCode, paymentData: action.paymentData, paymentMethodType: action.paymentMethodType)
    }

    static func document(_ action: DocumentAction) -> Action {
        Action(kind: .document(action), type: .voucher, paymentMethodType: action.paymentMethodType)
    }
}
