//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation

internal protocol AnyThreeDS2CoreActionHandler: Component {
    var threeDSRequestorAppURL: URL? { get set }
    
    var presentationDelegate: PresentationDelegate? { get set }
    
    func handle(
        _ fingerprintAction: ThreeDS2FingerprintAction,
        event: Analytics.Event,
        completionHandler: @escaping (Result<String, Error>) -> Void
    )
    
    func handle(
        _ challengeAction: ThreeDS2ChallengeAction,
        event: Analytics.Event,
        completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void
    )
}

internal typealias ThreeDSService = ThreeDSConfigurable & ThreeDSServiceable

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
internal class ThreeDS2CoreActionHandler: AnyThreeDS2CoreActionHandler {
    private enum Constants {
        static let transStatusWhenError = "U"
        static let fingerprintEvent = "threeDS2Fingerprint"
        static let challengeEvent = "threeDS2Challenge"
    }
    
    internal let context: AdyenContext

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    internal let appearanceConfiguration: ADYAppearanceConfiguration
    
    private var service: ThreeDSService
    
    internal weak var presentationDelegate: PresentationDelegate?
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
    internal var threeDSRequestorAppURL: URL?

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    internal init(
        context: AdyenContext,
        service: ThreeDSService,
        appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()
    ) {
        self.context = context
        self.appearanceConfiguration = appearanceConfiguration
        self.service = service
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    /// - Parameter event: The Analytics event.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(
        _ fingerprintAction: ThreeDS2FingerprintAction,
        event: Analytics.Event,
        completionHandler: @escaping (Result<String, Error>) -> Void
    ) {
        Analytics.sendEvent(event)
        sendLogEvent(.fingerprintSent, for: Constants.fingerprintEvent)
        
        do {
            let token = try AdyenCoder.decodeBase64(fingerprintAction.fingerprintToken) as ThreeDS2Component.FingerprintToken
            let serviceParameters = FingerprintServiceParameters(
                directoryServerIdentifier: token.directoryServerIdentifier,
                directoryServerPublicKey: token.directoryServerPublicKey,
                directoryServerRootCertificates: token.directoryServerRootCertificates,
                deviceExcludedParameters: nil,
                appearanceConfiguration: appearanceConfiguration,
                threeDSMessageVersion: token.threeDSMessageVersion
            )
            service.configuration = token.configuration
            service.performFingerprint(
                parameters: serviceParameters
            ) { result in
                self.sendLogEvent(.fingerprintComplete, for: Constants.fingerprintEvent)
                switch result {
                case let .success(authenticationRequestParameters):
                    self.didFinishFingerprintSuccessfully(
                        authenticationRequestParameters: authenticationRequestParameters,
                        completionHandler: completionHandler
                    )
                case let .failure(error):
                    self.didReceiveErrorOnFingerprint(
                        error: error,
                        completionHandler: completionHandler
                    )
                }
            }
            
        } catch {
            sendErrorEvent(.threeDS2DecodingFailed, for: Constants.fingerprintEvent)
            didFail(with: error, completionHandler: completionHandler)
        }
    }
        
    private func didReceiveErrorOnFingerprint(
        error: ThreeDSServiceFingerprintError,
        completionHandler: @escaping (Result<String, Error>) -> Void
    ) {
        let errorPayload: String = {
            switch error {
            case let .fingerprintingError(errorPayload: errorPayload):
                errorPayload
            }
        }()
        
        do {
            let encodedError = try AdyenCoder.encodeBase64(
                ThreeDS2Component.Fingerprint(
                    threeDS2SDKError: errorPayload
                )
            )
            completionHandler(.success(encodedError))
        } catch {
            sendErrorEvent(.threeDS2FingerprintHandlingFailed, for: Constants.fingerprintEvent)
            didFail(with: error, completionHandler: completionHandler)
        }
    }

    private func didFinishFingerprintSuccessfully(
        authenticationRequestParameters: AnyAuthenticationRequestParameters,
        completionHandler: @escaping (Result<String, Error>) -> Void
    ) {
        do {
            let encodedFingerprint = try AdyenCoder.encodeBase64(ThreeDS2Component.Fingerprint(
                authenticationRequestParameters: authenticationRequestParameters,
                delegatedAuthenticationSDKOutput: nil,
                deleteDelegatedAuthenticationCredential: nil
            ))
            completionHandler(.success(encodedFingerprint))
        } catch {
            sendErrorEvent(.threeDS2FingerprintCreationFailed, for: Constants.fingerprintEvent)
            didFail(with: error, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Challenge

    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    /// - Parameter event: The Analytics event.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(
        _ challengeAction: ThreeDS2ChallengeAction,
        event: Analytics.Event,
        completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void
    ) {
        Analytics.sendEvent(event)
        
        sendLogEvent(.challengeDataSent, for: Constants.challengeEvent)

        let token: ThreeDS2Component.ChallengeToken
        do {
            token = try AdyenCoder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
        } catch {
            sendErrorEvent(.threeDS2DecodingFailed, for: Constants.challengeEvent)
            return didFail(with: error, completionHandler: completionHandler)
        }
        let challengeParameters = ChallengeParameters(
            challengeToken: token,
            threeDSRequestorAppURL: threeDSRequestorAppURL ?? token.threeDSRequestorAppURL
        )
        
        sendLogEvent(.challengeDisplayed, for: Constants.challengeEvent)

        service.performChallenge(
            with: challengeParameters
        ) { [weak self] result in
            guard let self else { return }
            self.sendLogEvent(.challengeComplete, for: Constants.challengeEvent)
            switch result {
            case let .success(success):
                self.didFinishChallengeSuccessfully(
                    with: success,
                    authorizationToken: challengeAction.authorisationToken,
                    completionHandler: completionHandler
                )
            case let .failure(error):
                self.didReceiveErrorOnChallenge(
                    error: error,
                    challengeAction: challengeAction,
                    completionHandler: completionHandler
                )
            }
        }
    }
    
    internal func userCancelledChallenge() {}

    /// Invoked to handle the error flow of a challenge handling by the 3ds2sdk.
    private func didReceiveErrorOnChallenge(
        error: ThreeDSServiceChallengeError,
        challengeAction: ThreeDS2ChallengeAction,
        completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void
    ) {
        let opaqueRepresentationOfError: String
        switch error {
        case let .cancelled(errorPayload):
            userCancelledChallenge()
            opaqueRepresentationOfError = errorPayload
            sendErrorEvent(
                .threeDS2ChallengeHandlingFailed,
                for: Constants.challengeEvent,
                message: "cancelled"
            )

        case .transactionNotInitialized:
            sendErrorEvent(
                .threeDS2TransactionMissing,
                for: Constants.challengeEvent
            )
            return didFail(with: ThreeDS2Component.Error.missingTransaction, completionHandler: completionHandler)

        case let .challengeError(errorPayload),
             let .errorAndResultAreNil(errorPayload):
            opaqueRepresentationOfError = errorPayload
            sendErrorEvent(
                .threeDS2ChallengeHandlingFailed,
                for: Constants.challengeEvent
            )
        }
        
        do {
            // When we get an error we need to send transStatus as "U" along with the threeDS2SDKError field.
            let threeDSResult = try ThreeDSResult(
                authorizationToken: challengeAction.authorisationToken,
                threeDS2SDKError: opaqueRepresentationOfError,
                transStatus: Constants.transStatusWhenError
            )
            completionHandler(.success(threeDSResult))
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }
    
    private func didFinishChallengeSuccessfully(
        with challengeResult: AnyChallengeResult,
        authorizationToken: String?,
        completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void
    ) {
        do {
            let threeDSResult = try ThreeDSResult(
                from: challengeResult,
                delegatedAuthenticationSDKOutput: nil,
                authorizationToken: authorizationToken,
                threeDS2SDKError: nil
            )
            completionHandler(.success(threeDSResult))
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }
    
    private func didFail<R>(
        with error: Error,
        completionHandler: @escaping (Result<R, Error>) -> Void
    ) {
        service.resetTransaction()
        completionHandler(.failure(error))
    }

    // MARK: - Events {
    
    private func sendLogEvent(_ subtype: AnalyticsEventLog.LogSubType, for component: String) {
        let logEvent = AnalyticsEventLog(
            component: component,
            type: .threeDS2,
            subType: subtype
        )
        context.analyticsProvider?.add(log: logEvent)
    }
    
    private func sendErrorEvent(_ code: AnalyticsConstants.ErrorCode, for component: String, message: String? = nil) {
        var errorEvent = AnalyticsEventError(component: component, type: .threeDS2)
        errorEvent.code = code.stringValue
        errorEvent.message = message
        context.analyticsProvider?.add(error: errorEvent)
    }
}

extension ThreeDS2CoreActionHandler: PresentationDelegate {
    func present(component: any PresentableComponent) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        presentationDelegate?.present(component: component)
    }
}
