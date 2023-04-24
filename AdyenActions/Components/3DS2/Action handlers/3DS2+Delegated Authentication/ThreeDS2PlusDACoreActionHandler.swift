//
// Copyright (c) 2023 Adyen N.V.
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
    internal class ThreeDS2PlusDACoreActionHandler: ThreeDS2CoreActionHandler {
        
        internal var delegatedAuthenticationState: DelegatedAuthenticationState = .init()
        
        /// Delegates `PresentableComponent`'s presentation.
        internal weak var presentationDelegate: PresentationDelegate?

        internal struct DelegatedAuthenticationState {
            enum UserInputState {
                case approveDifferently
                case deleteDA
                case noInput
            }

            internal var state: UserInputState = .noInput
            internal var isDeviceRegistrationFlow: Bool = false
        }
        
        private let delegatedAuthenticationService: AuthenticationServiceProtocol

        /// Initializes the 3D Secure 2 action handler.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter appearanceConfiguration: The appearance configuration.
        /// - Parameter delegatedAuthenticationConfiguration: The delegated authentication configuration.
        internal convenience init(
            context: AdyenContext,
            appearanceConfiguration: ADYAppearanceConfiguration,
            delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication,
            presentationDelegate: PresentationDelegate?
        ) {
            self.init(
                context: context,
                appearanceConfiguration: appearanceConfiguration,
                delegatedAuthenticationService: AuthenticationService(
                    configuration: delegatedAuthenticationConfiguration.authenticationServiceConfiguration()
                ),
                presentationDelegate: presentationDelegate
            )
        }
        
        /// Initializes the 3D Secure 2 action handler.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter service: The 3DS2 Service.
        /// - Parameter appearanceConfiguration: The appearance configuration.
        /// - Parameter delegatedAuthenticationService: The Delegated Authentication service.
        internal init(context: AdyenContext,
                      service: AnyADYService = ADYServiceAdapter(),
                      appearanceConfiguration: ADYAppearanceConfiguration = .init(),
                      delegatedAuthenticationService: AuthenticationServiceProtocol,
                      presentationDelegate: PresentationDelegate?) {
            self.delegatedAuthenticationService = delegatedAuthenticationService
            super.init(context: context, service: service, appearanceConfiguration: appearanceConfiguration)
            self.presentationDelegate = presentationDelegate
        }

        // MARK: - Fingerprint

        /// Handles the 3D Secure 2 fingerprint action.
        ///
        /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
        /// - Parameter event: The Analytics event.
        /// - Parameter completionHandler: The completion closure.
        override internal func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                                      event: Analytics.Event,
                                      completionHandler: @escaping (Result<String, Error>) -> Void) {
            super.handle(fingerprintAction, event: event) { [weak self] result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(fingerprintResult):
                    self?.addSDKOutputIfNeeded(toFingerprintResult: fingerprintResult,
                                               fingerprintAction,
                                               completionHandler: completionHandler)
                }
            }
        }
        
        private func addSDKOutputIfNeeded(toFingerprintResult fingerprintResult: String, _ fingerprintAction: ThreeDS2FingerprintAction, completionHandler: @escaping (Result<String, Error>) -> Void) {
            do {
                let token = try Coder.decodeBase64(fingerprintAction.fingerprintToken) as ThreeDS2Component.FingerprintToken
                let fingerprintResult: ThreeDS2Component.Fingerprint = try Coder.decodeBase64(fingerprintResult)
                performDelegatedAuthentication(token) { [weak self] result in
                    guard let self = self else { return }
                    self.delegatedAuthenticationState.isDeviceRegistrationFlow = result.successResult == nil
                    guard let fingerprintResult = self.createFingerPrintResult(authenticationSDKOutput: result.successResult,
                                                                               fingerprintResult: fingerprintResult,
                                                                               completionHandler: completionHandler) else { return }
                    completionHandler(.success(fingerprintResult))
                }
            } catch {
                didFail(with: error, completionHandler: completionHandler)
            }
            
        }
        
        /// This method checks;
        /// 1. if DA has been registered on the device
        /// 2. shows an approval screen if it has been registered
        /// else calls the completion with a failure.
        private func performDelegatedAuthentication(_ fingerprintToken: ThreeDS2Component.FingerprintToken,
                                                    completion: @escaping (Result<String, DelegateAuthenticationError>) -> Void) {
            guard let delegatedAuthenticationInput = fingerprintToken.delegatedAuthenticationSDKInput else {
                completion(.failure(DelegateAuthenticationError.authenticationFailed(cause: nil)))
                return
            }
            
            isDeviceRegisteredForDelegatedAuthentication(
                delegatedAuthenticationInput: delegatedAuthenticationInput,
                registeredHandler: { [weak self] in
                    guard let self else { return }
                    showApprovalScreen(useDAHandler: {
                        self.delegatedAuthenticationService.authenticate(withAuthenticationInput: delegatedAuthenticationInput) { result in
                            switch result {
                            case let .success(sdkOutput):
                                completion(.success(sdkOutput))
                            case let .failure(error):
                                completion(.failure(DelegateAuthenticationError.authenticationFailed(cause: error)))
                            }
                        }
                    }, doNotUseDAHandler: {
                        completion(.failure(DelegateAuthenticationError.authenticationFailed(cause: nil)))
                    })
                },
                notRegisteredHandler: {
                    completion(.failure(DelegateAuthenticationError.authenticationFailed(cause: nil)))
                }
            )
        }
        
        private func isDeviceRegisteredForDelegatedAuthentication(delegatedAuthenticationInput: String,
                                                                  registeredHandler: @escaping () -> Void,
                                                                  notRegisteredHandler: @escaping () -> Void) {
            delegatedAuthenticationService.isDeviceRegistered(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case .failure:
                    notRegisteredHandler()
                case let .success(success):
                    if success {
                        registeredHandler()
                    } else {
                        notRegisteredHandler()
                    }
                }
            }
        }
        
        private func showApprovalScreen(useDAHandler: @escaping () -> Void,
                                        doNotUseDAHandler: @escaping () -> Void) {
            let approvalViewController = DAApprovalViewController(useBiometricsHandler: {
                useDAHandler()
            }, approveDifferentlyHandler: {
                self.delegatedAuthenticationState.state = .approveDifferently
                doNotUseDAHandler()
            }, removeCredentialsHandler: {
                print("Remove credentials")
                self.delegatedAuthenticationState.state = .deleteDA
                try? self.delegatedAuthenticationService.reset()
                doNotUseDAHandler()
            })
            
            let presentableComponent = PresentableComponentWrapper(component: self,
                                                                   viewController: approvalViewController)
            self.presentationDelegate?.present(component: presentableComponent)
        }
        
        private func createFingerPrintResult<R>(authenticationSDKOutput: String?,
                                                fingerprintResult: ThreeDS2Component.Fingerprint,
                                                completionHandler: @escaping (Result<R, Error>) -> Void) -> String? {
            do {
                let fingerprintResult = fingerprintResult.withDelegatedAuthenticationSDKOutput(
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
        override internal func handle(_ challengeAction: ThreeDS2ChallengeAction,
                                      event: Analytics.Event,
                                      completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
            super.handle(challengeAction, event: event) { [weak self] result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(challengeResult):
                    self?.addSDKOutputIfNeeded(toChallengeResult: challengeResult, challengeAction, completionHandler: completionHandler)
                }
            }
        }
        
        private func addSDKOutputIfNeeded(toChallengeResult challengeResult: ThreeDSResult,
                                          _ challengeAction: ThreeDS2ChallengeAction,
                                          completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
            let token: ThreeDS2Component.ChallengeToken
            do {
                token = try Coder.decodeBase64(challengeAction.challengeToken) as ThreeDS2Component.ChallengeToken
            } catch {
                return didFail(with: error, completionHandler: completionHandler)
            }
            
            if shouldShowRegistrationScreen {
                showRegistrationScreen(registerHandler: {
                                           self.performDelegatedRegistration(token.delegatedAuthenticationSDKInput) { [weak self] result in
                                               self?.deliver(challengeResult: challengeResult,
                                                             delegatedAuthenticationSDKOutput: result.successResult,
                                                             completionHandler: completionHandler)
                                           }
                                       },
                                       notNowHandler: {
                                           completionHandler(.success(challengeResult))
                                       })
            } else {
                completionHandler(.success(challengeResult))
            }
        }
        
        internal var shouldShowRegistrationScreen: Bool {
            delegatedAuthenticationState.isDeviceRegistrationFlow
                && delegatedAuthenticationState.state != .approveDifferently
                && delegatedAuthenticationState.state != .deleteDA
        }
        
        internal func showRegistrationScreen(registerHandler: @escaping () -> Void, notNowHandler: @escaping () -> Void) {
            let registrationViewController = DARegistrationViewController(enableCheckoutHandler: {
                registerHandler()
            }, notNowHandler: {
                notNowHandler()
            })
            
            let presentableComponent = PresentableComponentWrapper(component: self,
                                                                   viewController: registrationViewController)
            
            presentationDelegate?.present(component: presentableComponent)
        }
        
        internal func performDelegatedRegistration(_ sdkInput: String?,
                                                   completion: @escaping (Result<String, Error>) -> Void) {
            guard let sdkInput = sdkInput else {
                completion(.failure(DelegateAuthenticationError.registrationFailed(cause: nil)))
                return
            }
            delegatedAuthenticationService.register(withRegistrationInput: sdkInput) { result in
                switch result {
                case let .success(sdkOutput):
                    completion(.success(sdkOutput))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }

        private func deliver(challengeResult: ThreeDSResult,
                             delegatedAuthenticationSDKOutput: String?,
                             completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {

            do {
                let threeDSResult = try challengeResult.withDelegatedAuthenticationSDKOutput(
                    delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput
                )

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
        internal var successResult: Success? {
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
                  appleTeamIdendtifier: appleTeamIdentifier)
        }
    }

#endif
