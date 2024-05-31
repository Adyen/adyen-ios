//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import class Adyen3DS2.ADYAppearanceConfiguration
import Foundation

internal protocol AnyThreeDS2CoreActionHandler: Component {
    var threeDSRequestorAppURL: URL? { get set }
    
    var service: ThreeDSServiceProtocol? { get set }
//
//    var transaction: AnyADYTransaction? { get set }
    
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                event: Analytics.Event,
                completionHandler: @escaping (Result<String, Error>) -> Void)
    
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                event: Analytics.Event,
                completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void)
}

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

    internal var service: ThreeDSServiceProtocol?
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
    internal var threeDSRequestorAppURL: URL?

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    internal init(context: AdyenContext,
                  service: ThreeDSServiceProtocol? = nil,
                  appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration()) {
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
    internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                         event: Analytics.Event,
                         completionHandler: @escaping (Result<String, Error>) -> Void) {
        Analytics.sendEvent(event)
        sendFingerPrintEvent(.fingerprintSent)
        
        createFingerprint(fingerprintAction) { [weak self] result in
            guard let self else { return }
            
            self.sendFingerPrintEvent(.fingerprintComplete)
            
            switch result {
            case let .success(encodedFingerprint):
                completionHandler(.success(encodedFingerprint))
            case let .failure(error):
                self.didFail(with: error, completionHandler: completionHandler)
            }
        }
    }
    
    private func createFingerprint(_ action: ThreeDS2FingerprintAction,
                                   completionHandler: @escaping (Result<String, Error>) -> Void) {
        do {
            let token = try AdyenCoder.decodeBase64(action.fingerprintToken) as ThreeDS2Component.FingerprintToken
            let service: any ThreeDSServiceProtocol = if let service = self.service {
                service
            } else if token.sdkToUse == "swift" {
                if #available(iOS 13, *) {
                    ThreeDSService()
                } else {
                    ThreeDSServiceLegacy()
                }
            } else {
                ThreeDSServiceLegacy()
            }
            
            self.service = service
            
            service.authenticationParameters(parameters:
                .init(directoryServerIdentifier: token.directoryServerIdentifier,
                      directoryServerPublicKey: token.directoryServerPublicKey,
                      directoryServerRootCertificates: token.directoryServerRootCertificates,
                      deviceExcludedParameters: nil,
                      appearanceConfiguration: appearanceConfiguration,
                      threeDSMessageVersion: token.threeDSMessageVersion)) { [weak self] result in
                guard let self else { return }
                do {
                    switch result {
                    case let .success(success):
                        let encodedFingerprint = try AdyenCoder.encodeBase64(ThreeDS2Component.Fingerprint(
                            authenticationRequestParameters: success,
                            delegatedAuthenticationSDKOutput: nil
                        ))
                        completionHandler(.success(encodedFingerprint))
                        
                    case let .failure(failure as NSError):
                        if let sdkError = service.opaqueErrorObject(error: failure) {
                            let encodedError = try AdyenCoder.encodeBase64(ThreeDS2Component.Fingerprint(
                                threeDS2SDKError: sdkError)
                            )
                            completionHandler(.success(encodedError))
                        } else {
                            self.didFail(with: failure, completionHandler: completionHandler)
                        }
                    }
                } catch {
                    self.didFail(with: error, completionHandler: completionHandler)
                }
            }
        } catch {
            didFail(with: error, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Challenge

    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    /// - Parameter event: The Analytics event.
    /// - Parameter completionHandler: The completion closure.
    internal func handle(_ challengeAction: ThreeDS2ChallengeAction,
                         event: Analytics.Event,
                         completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        Analytics.sendEvent(event)
        
        sendChallengeEvent(.challengeDataSent)
        
        guard let service else {
            return didFail(with: ThreeDS2Component.Error.missingTransaction, completionHandler: completionHandler)
        }

        let token: ThreeDS2Component.ChallengeToken
        do {
            token = try AdyenCoder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
        } catch {
            return didFail(with: error, completionHandler: completionHandler)
        }

        sendChallengeEvent(.challengeDisplayed)

        service.performChallenge(with: .init(challengeToken: token,
                                             threeDSRequestorAppURL: threeDSRequestorAppURL ?? token.threeDSRequestorAppURL)) { [weak self] result in
            guard let self else { return }
            self.sendChallengeEvent(.challengeComplete)

            switch result {
            case let .success(success):
                self.didFinish(with: success,
                               authorizationToken: challengeAction.authorisationToken,
                               completionHandler: completionHandler)
            case let .failure(failure):
                switch failure {
                case .transactionNotInitialized:
                    return self.didFail(with: ThreeDS2Component.Error.missingTransaction, completionHandler: completionHandler)
                case let .unknownError(unknownError):
                    return self.didFail(with: unknownError, completionHandler: completionHandler)
                case let .challengeError(error):
                    self.didReceiveErrorOnChallenge(error: error,
                                                    challengeAction: challengeAction,
                                                    completionHandler: completionHandler)
                }
            }
        }
    }
    
    /// Invoked to handle the error flow of a challenge handling by the 3ds2sdk.
    /// For challenge cancelled we return the control back to the merchant immediately as an error.
    private func didReceiveErrorOnChallenge(error: Error,
                                            challengeAction: ThreeDS2ChallengeAction,
                                            completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        switch service.isCancelled(error: error) {
        case true:
            didFail(with: error,
                    completionHandler: completionHandler)
        case false:
            if let opaqueError = service.opaqueErrorObject(error: error) {
                didFinish(threeDS2SDKError: opaqueError,
                          authorizationToken: challengeAction.authorisationToken,
                          completionHandler: completionHandler)
            } else {
                didFail(with: error,
                        completionHandler: completionHandler)
            }
        }
    }
    
    private func didFinish(threeDS2SDKError: String,
                           authorizationToken: String?,
                           completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        do {
            // When we get an error we need to send transStatus as "U" along with the threeDS2SDKError field.
            let threeDSResult = try ThreeDSResult(authorizationToken: authorizationToken,
                                                  threeDS2SDKError: threeDS2SDKError,
                                                  transStatus: Constants.transStatusWhenError)
            service.resetTransaction()
            completionHandler(.success(threeDSResult))
        } catch {
            completionHandler(.failure(error))
        }
    }

    private func didFinish(with challengeResult: AnyChallengeResult,
                           authorizationToken: String?,
                           completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        do {
            let threeDSResult = try ThreeDSResult(from: challengeResult,
                                                  delegatedAuthenticationSDKOutput: nil,
                                                  authorizationToken: authorizationToken,
                                                  threeDS2SDKError: nil)

            service.resetTransaction()
            completionHandler(.success(threeDSResult))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    private func didFail<R>(with error: Error,
                            completionHandler: @escaping (Result<R, Error>) -> Void) {
        service.resetTransaction()

        completionHandler(.failure(error))
    }
    
    // MARK: - Events {
    
    private func sendFingerPrintEvent(_ subtype: AnalyticsEventLog.LogSubType) {
        let logEvent = AnalyticsEventLog(
            component: Constants.fingerprintEvent,
            type: .threeDS2,
            subType: subtype
        )
        context.analyticsProvider?.add(log: logEvent)
    }
    
    private func sendChallengeEvent(_ subtype: AnalyticsEventLog.LogSubType) {
        let logEvent = AnalyticsEventLog(
            component: Constants.challengeEvent,
            type: .threeDS2,
            subType: subtype
        )
        context.analyticsProvider?.add(log: logEvent)
    }
}
