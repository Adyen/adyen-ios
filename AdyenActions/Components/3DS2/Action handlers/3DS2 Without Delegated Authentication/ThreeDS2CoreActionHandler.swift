//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2_Swift
import Foundation

internal protocol AnyThreeDS2CoreActionHandler: Component {
    var threeDSRequestorAppURL: URL? { get set }
    
    var service: AnyADYService { get set }
    
    var transaction: AnyADYTransaction? { get set }
    
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                event: Analytics.Event,
                completionHandler: @escaping (Result<String, Error>) -> Void)
    
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                event: Analytics.Event,
                completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void)
}

/// Handles the 3D Secure 2 fingerprint and challenge actions separately.
internal class ThreeDS2CoreActionHandler: AnyThreeDS2CoreActionHandler {
    private enum Constant {
        static let transStatusWhenError = "U"
    }
    
    internal let context: AdyenContext

    /// The appearance configuration of the 3D Secure 2 challenge UI.
    internal let appearanceConfiguration: ADYAppearanceConfiguration

    internal lazy var service: AnyADYService = ADYServiceAdapter()

    internal var transaction: AnyADYTransaction?
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
    internal var threeDSRequestorAppURL: URL?

    /// Initializes the 3D Secure 2 action handler.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter service: The 3DS2 Service.
    /// - Parameter appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
    internal init(context: AdyenContext,
                  service: AnyADYService = ADYServiceAdapter(),
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

        createFingerprint(fingerprintAction) { [weak self] result in
            switch result {
            case let .success(encodedFingerprint):
                completionHandler(.success(encodedFingerprint))
            case let .failure(error):
                self?.didFail(with: error, completionHandler: completionHandler)
            }
        }
    }
    
    private func createFingerprint(_ action: ThreeDS2FingerprintAction,
                                   completionHandler: @escaping (Result<String, Error>) -> Void) {
        do {
            let token = try AdyenCoder.decodeBase64(action.fingerprintToken) as ThreeDS2Component.FingerprintToken
            
            let serviceParameters = try ServiceParameters(directoryServerIdentifier: token.directoryServerIdentifier,
                                                          directoryServerPublicKey: token.directoryServerPublicKey,
                                                          
                                                          directoryServerRootCertificates: token.directoryServerRootCertificates)
            
            service.transaction(withMessageVersion: token.threeDSMessageVersion,
                                parameters: serviceParameters,
                                appearanceConfiguration: appearanceConfiguration) { result in
                do {
                    switch result {
                    case let .success(success):
                        let encodedFingerprint = try AdyenCoder.encodeBase64(ThreeDS2Component.Fingerprint(
                            authenticationRequestParameters: success.authenticationParameters,
                            delegatedAuthenticationSDKOutput: nil
                        ))
                        self.transaction = success
                        completionHandler(.success(encodedFingerprint))
                    case let .failure(failure as ThreeDSError):
                        let encodedError = try AdyenCoder.encodeBase64(ThreeDS2Component.Fingerprint(
                            threeDS2SDKError: failure.base64Representation
                        ))
                        completionHandler(.success(encodedError))
                    case let .failure(error):
                        completionHandler(.failure(error))
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
        guard let transaction else {
            return didFail(with: ThreeDS2Component.Error.missingTransaction, completionHandler: completionHandler)
        }

        Analytics.sendEvent(event)

        let token: ThreeDS2Component.ChallengeToken
        do {
            token = try AdyenCoder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
        } catch {
            return didFail(with: error, completionHandler: completionHandler)
        }
        let challengeParameters = ChallengeParameters(serverTransactionIdentifier: token.serverTransactionIdentifier,
                                                      threeDSRequestorAppURL: token.threeDSRequestorAppURL,
                                                      acsTransactionIdentifier: token.acsTransactionIdentifier,
                                                      acsReferenceNumber: token.acsReferenceNumber,
                                                      acsSignedContent: token.acsSignedContent)

        transaction.performChallenge(with: challengeParameters, presenterViewController: getPresenterViewController()) { result in
            switch result {
            case let .success(success):
                self.didFinish(with: success,
                               authorizationToken: challengeAction.authorisationToken,
                               completionHandler: completionHandler)
            case let .failure(failure):
                self.didReceiveErrorOnChallenge(error: failure, challengeAction: challengeAction, completionHandler: completionHandler)
            }
        }
    }
    
    private func getPresenterViewController() -> UIViewController {
        // TODO: Robert: How do i get the presenterViewController if it  doesn't break public API.
        // Maybe we can re-use the logic how we used to get it in the sdk earlier, but optionally allow it to be configured.
        (UIApplication.shared.keyWindow?.topViewController)!
    }
    
    /// Invoked to handle the error flow of a challenge handling by the 3ds2sdk.
    /// For challenge cancelled we return the control back to the merchant immediately as an error.
    private func didReceiveErrorOnChallenge(error: Error?,
                                            challengeAction: ThreeDS2ChallengeAction,
                                            completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        guard let error = error as? ThreeDSError else {
            didFail(with: UnknownError(errorDescription: "Unknown error returned by the SDK."),
                    completionHandler: completionHandler)
            return
        }
        if error.errorCode == "1001" {
            didFail(with: error,
                    completionHandler: completionHandler)
        } else {
            didFinish(threeDS2SDKError: error.base64Representation,
                      authorizationToken: challengeAction.authorisationToken,
                      completionHandler: completionHandler)
        }
    }
    
    private func didFinish(threeDS2SDKError: String,
                           authorizationToken: String?,
                           completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
        do {
            // When we get an error we need to send transStatus as "U" along with the threeDS2SDKError field.
            let threeDSResult = try ThreeDSResult(authorizationToken: authorizationToken,
                                                  threeDS2SDKError: threeDS2SDKError,
                                                  transStatus: Constant.transStatusWhenError)
            transaction = nil
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

            transaction = nil
            completionHandler(.success(threeDSResult))
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    private func didFail<R>(with error: Error,
                            completionHandler: @escaping (Result<R, Error>) -> Void) {
        transaction = nil

        completionHandler(.failure(error))
    }

}

extension UIWindow {
    internal var topViewController: UIViewController? {
        var topViewController = rootViewController
        while topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        }
        return topViewController
    }
}
