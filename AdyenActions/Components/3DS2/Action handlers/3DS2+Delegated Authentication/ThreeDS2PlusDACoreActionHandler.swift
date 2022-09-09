//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenAuthentication)
    @_spi(AdyenInternal) import Adyen
    import Adyen3DS2
    import AdyenAuthentication
    import Foundation
    import UIKit

    internal enum DelegateAuthenticationError: LocalizedError {
        case registrationFailed(cause: Error?)
        case authenticationFailed(cause: Error?)
    
        internal var errorDescription: String? {
            switch self {
            case let .registrationFailed(causeError):
                if let causeError = causeError {
                    return "Registration failure caused by error: { \(causeError.localizedDescription) }"
                } else {
                    return "Registration failure."
                }
            case let .authenticationFailed(causeError):
                if let causeError = causeError {
                    return "Authentication failure caused by error: { \(causeError.localizedDescription) }"
                } else {
                    return "Authentication failure."
                }
            }
        }
    }

    /// Handles the 3D Secure 2 fingerprint and challenge actions separately + Delegated Authentication.
    @available(iOS 14.0, *)
    internal class ThreeDS2PlusDACoreActionHandler: AnyThreeDS2CoreActionHandler {
    
        internal let context: AdyenContext

        /// The appearance configuration of the 3D Secure 2 challenge UI.
        internal let appearanceConfiguration: ADYAppearanceConfiguration

        internal var service: AnyADYService

        internal var transaction: AnyADYTransaction?
        
        private var delegatedAuthenticationState: DelegatedAuthenticationState = .init()
        
        private struct DelegatedAuthenticationState {
            internal var isDeviceRegistrationFlow: Bool = false
        }
        
        private let delegatedAuthenticationService: AuthenticationServiceProtocol
        
        /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
        internal var threeDSRequestorAppURL: URL?

        /// Initializes the 3D Secure 2 action handler.
        internal convenience init(
            context: AdyenContext,
            appearanceConfiguration: ADYAppearanceConfiguration,
            delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication
        ) {
            self.init(
                context: context,
                service: ADYServiceAdapter(),
                appearanceConfiguration: appearanceConfiguration,
                delegatedAuthenticationService: AuthenticationService(
                    configuration: delegatedAuthenticationConfiguration.authenticationServiceConfiguration()
                )
            )
        }
        
        /// Initializes the 3D Secure 2 action handler.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter service: The 3DS2 Service.
        /// - Parameter appearanceConfiguration: The appearance configuration.
        /// - Parameter delegatedAuthenticationService: The Delegated Authentication service.
        /// - Parameter delegatedAuthenticationConfiguration: The delegated authentication configuration.
        internal init(context: AdyenContext,
                      service: AnyADYService,
                      appearanceConfiguration: ADYAppearanceConfiguration = .init(),
                      delegatedAuthenticationService: AuthenticationServiceProtocol) {
            self.context = context
            self.service = service
            self.appearanceConfiguration = appearanceConfiguration
            self.delegatedAuthenticationService = delegatedAuthenticationService
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
            
            delegatedAuthenticationState = .init()

            createFingerprint(fingerprintAction) { [weak self] result in
                switch result {
                case let .success(fingerprint):
                    completionHandler(.success(fingerprint))
                case let .failure(error):
                    self?.didFail(with: error, completionHandler: completionHandler)
                }
            }
        }

        private func createFingerprint(_ fingerprintAction: ThreeDS2FingerprintAction,
                                       completionHandler: @escaping (Result<String, Error>) -> Void) {
            do {
                let token = try Coder.decodeBase64(fingerprintAction.fingerprintToken) as ThreeDS2Component.FingerprintToken

                let serviceParameters = ADYServiceParameters()
                serviceParameters.directoryServerIdentifier = token.directoryServerIdentifier
                serviceParameters.directoryServerPublicKey = token.directoryServerPublicKey
                serviceParameters.directoryServerRootCertificates = token.directoryServerRootCertificates

                service.service(with: serviceParameters, appearanceConfiguration: appearanceConfiguration) { [weak self] _ in
                    guard let fingerprintParameters = self?.getFingerprint(messageVersion: token.threeDSMessageVersion,
                                                                           completionHandler: completionHandler) else {
                        AdyenAssertion.assertionFailure(message: "This should never happen!!")
                        return
                    }
                    
                    self?.performDelegatedAuthentication(token) { result in
                        guard let self = self else { return }
                        self.delegatedAuthenticationState.isDeviceRegistrationFlow = result.successResult == nil
                        guard let fingerprintResult = self.createFingerPrintResult(authenticationSDKOutput: result.successResult,
                                                                                   fingerprintParameters: fingerprintParameters,
                                                                                   completionHandler: completionHandler) else { return }
                        completionHandler(.success(fingerprintResult))
                    }
                }
            } catch {
                didFail(with: error, completionHandler: completionHandler)
            }
        }

        private func getFingerprint<R>(messageVersion: String, completionHandler: @escaping (Result<R, Error>) -> Void) -> AnyAuthenticationRequestParameters? {
            do {
                let newTransaction = try service.transaction(withMessageVersion: messageVersion)
                self.transaction = newTransaction
                return newTransaction.authenticationParameters
            } catch {
                didFail(with: error, completionHandler: completionHandler)
                return nil
            }
        }
        
        internal func performDelegatedAuthentication(_ fingerprintToken: ThreeDS2Component.FingerprintToken,
                                                     completion: @escaping (Result<String, DelegateAuthenticationError>) -> Void) {
            guard let delegatedAuthenticationInput = fingerprintToken.delegatedAuthenticationSDKInput else {
                completion(.failure(DelegateAuthenticationError.authenticationFailed(cause: nil)))
                return
            }
            delegatedAuthenticationService.authenticate(withBase64URLString: delegatedAuthenticationInput) { result in
                switch result {
                case let .success(sdkOutput):
                    completion(.success(sdkOutput))
                case let .failure(error):
                    completion(.failure(DelegateAuthenticationError.authenticationFailed(cause: error)))
                }
            }
        }
        
        private func createFingerPrintResult<R>(authenticationSDKOutput: String?,
                                                fingerprintParameters: AnyAuthenticationRequestParameters,
                                                completionHandler: @escaping (Result<R, Error>) -> Void) -> String? {
            do {
                let fingerprintResult = try ThreeDS2Component.Fingerprint(
                    authenticationRequestParameters: fingerprintParameters,
                    delegatedAuthenticationSDKOutput: authenticationSDKOutput
                )
                let encodedFingerprintResult = try Coder.encodeBase64(fingerprintResult)
                return encodedFingerprintResult
            } catch {
                didFail(with: error, completionHandler: completionHandler)
            }
            return nil
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
            guard let transaction = transaction else {
                return didFail(with: ThreeDS2Component.Error.missingTransaction, completionHandler: completionHandler)
            }

            Analytics.sendEvent(event)

            let token: ThreeDS2Component.ChallengeToken
            do {
                token = try Coder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
            } catch {
                return didFail(with: error, completionHandler: completionHandler)
            }

            let challengeParameters = ADYChallengeParameters(challengeToken: token,
                                                             threeDSRequestorAppURL: threeDSRequestorAppURL)
            transaction.performChallenge(with: challengeParameters) { [weak self] challengeResult, error in
                guard let self = self, let challengeResult = challengeResult else {
                    let error = error ?? UnknownError(errorDescription: "Both error and result are nil, this should never happen.")
                    self?.didFail(with: error, completionHandler: completionHandler)
                    return
                }
                
                if self.delegatedAuthenticationState.isDeviceRegistrationFlow {
                    self.performDelegatedRegistration(token.delegatedAuthenticationSDKInput) { result in
                        self.didFinish(with: challengeResult,
                                       delegatedAuthenticationSDKOutput: result.successResult,
                                       authorizationToken: challengeAction.authorisationToken,
                                       completionHandler: completionHandler)
                    }
                } else {
                    self.didFinish(with: challengeResult,
                                   delegatedAuthenticationSDKOutput: nil,
                                   authorizationToken: challengeAction.authorisationToken,
                                   completionHandler: completionHandler)
                }
            }

        }
        
        internal func performDelegatedRegistration(_ sdkInput: String?,
                                                   completion: @escaping (Result<String, Error>) -> Void) {
            guard let sdkInput = sdkInput else {
                completion(.failure(DelegateAuthenticationError.registrationFailed(cause: nil)))
                return
            }
            delegatedAuthenticationService.register(withBase64URLString: sdkInput) { result in
                switch result {
                case let .success(sdkOutput):
                    completion(.success(sdkOutput))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }

        private func didFinish(with challengeResult: AnyChallengeResult,
                               delegatedAuthenticationSDKOutput: String?,
                               authorizationToken: String?,
                               completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {

            do {
                let threeDSResult = try ThreeDSResult(from: challengeResult,
                                                      delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput,
                                                      authorizationToken: authorizationToken)

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

    extension Result {
        var successResult: Success? {
            switch self {
            case let .success(successResult):
                return successResult
            case .failure:
                return nil
            }
        }
    }

    @available(iOS 14.0, *)
    extension ThreeDS2Component.Configuration.DelegatedAuthentication {
        fileprivate func authenticationServiceConfiguration() -> AuthenticationService.Configuration {
            .init(localizedRegistrationReason: localizedRegistrationReason,
                  localizedAuthenticationReason: localizedAuthenticationReason,
                  appleTeamIdendtifier: appleTeamIdendtifier)
        }
    }

#endif
