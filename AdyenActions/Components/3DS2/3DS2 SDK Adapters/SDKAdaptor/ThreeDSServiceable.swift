//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import class Adyen3DS2.ADYAppearanceConfiguration
import Foundation
@_spi(AdyenInternal) import Adyen

internal struct ChallengeParameters {
    internal let challengeToken: ThreeDS2Component.ChallengeToken
    internal let threeDSRequestorAppURL: URL?
}

internal struct ServiceParameters {
    internal let directoryServerIdentifier: String
    internal let directoryServerPublicKey: String
    internal let directoryServerRootCertificates: String
    internal let deviceExcludedParameters: [String: Any]?
    internal let appearanceConfiguration: Adyen3DS2.ADYAppearanceConfiguration
    internal let threeDSMessageVersion: String
}

internal enum ThreeDSServiceFingerprintError: Error {
    case fingerprintingError(errorPayload: String)
    case transactionCreationError(errorPayload: String)
    case serviceParameterCreationError(errorPayload: String)
    case messageVersionCreationError(errorPayload: String)
}

internal enum ThreeDSServiceError: Error {
    case transactionNotInitialized(errorPayload: String)
    case errorAndResultAreNil(errorPayload: String)
    case cancelled(errorPayload: String)
    case challengeError(errorPayload: String)
    case challengeResultNotHandled(errorPayload: String)
    case topViewControllerCouldNotBeDetermined(errorPayload: String)
}

internal protocol ThreeDSServiceable {
    func authenticationParameters(
        parameters: ServiceParameters,
        completionHandler: @escaping (Result<AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    )
    func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (Result<AnyChallengeResult, ThreeDSServiceError>) -> Void
    )
    func opaqueErrorObject(error: Error) -> String
    func resetTransaction()
}

extension UnknownError {
    internal static let invalidMessageVersion = UnknownError(errorDescription: "Invalid message version")
    internal static let transactionNotInitialized = UnknownError(errorDescription: "Transaction not initialized")
    internal static let resultAndErrorAreNil = UnknownError(errorDescription: "Both error and result are nil, this should never happen.")
    internal static let topViewControllerNotDetermined = UnknownError(errorDescription: "topViewController Not Determined")
}
