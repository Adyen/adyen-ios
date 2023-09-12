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
                if let causeError {
                    return "Registration failure caused by error: { \(causeError.localizedDescription) }"
                } else {
                    return "Registration failure."
                }
            case let .authenticationFailed(causeError):
                if let causeError {
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
        
        internal struct DelegatedAuthenticationState {
            internal var isDeviceRegistrationFlow: Bool = false
        }
    
        private let delegatedAuthenticationService: AuthenticationServiceProtocol
        private let deviceSupportCheckerService: AdyenAuthentication.DeviceSupportCheckerProtocol
        private let presenter: ThreeDS2PlusDAScreenPresenterProtocol
        
        /// Errors during the Delegated authentication flow
        private enum ThreeDS2PlusDACoreActionError: Error {
            /// When the backend doesn't support delegated authentication, so the threeDSToken doesn't contain the `sdkInput` parameter
            case sdkInputNotAvailableForApproval
            /// When the device is not registered for delegated authentication.
            case deviceIsNotRegistered
            /// When the `sdkInput` parameter is not available in the threeDStoken, this occurs during the registration flow.
            case sdkInputNotAvailableForRegistration
            /// When the user doesn't provide consent to use delegated authentication for the transaction during an approval flow.
            case noConsentForApproval
        }

        /// Initializes the 3D Secure 2 action handler.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter appearanceConfiguration: The appearance configuration.
        /// - Parameter delegatedAuthenticationConfiguration: The delegated authentication configuration.
        /// - Parameter presentationDelegate: The presentation delegate
        internal convenience init(
            context: AdyenContext,
            appearanceConfiguration: ADYAppearanceConfiguration,
            delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication,
            presentationDelegate: PresentationDelegate?
        ) {
            self.init(
                context: context,
                presenter: ThreeDS2PlusDAScreenPresenter(presentationDelegate: presentationDelegate,
                                                         style: .init(),
                                                         localizedParameters: delegatedAuthenticationConfiguration.localizationParameters),
                appearanceConfiguration: appearanceConfiguration,
                style: delegatedAuthenticationConfiguration.delegatedAuthenticationComponentStyle,
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
        /// - Parameter style: The delegate authentication component style.
        /// - Parameter delegatedAuthenticationService: The Delegated Authentication service.
        /// - Parameter presentationDelegate: Presentation delegate
        internal init(context: AdyenContext,
                      service: AnyADYService = ADYServiceAdapter(),
                      presenter: ThreeDS2PlusDAScreenPresenterProtocol,
                      appearanceConfiguration: ADYAppearanceConfiguration = .init(),
                      style: DelegatedAuthenticationComponentStyle = .init(),
                      delegatedAuthenticationService: AuthenticationServiceProtocol,
                      deviceSupportCheckerService: AdyenAuthentication.DeviceSupportCheckerProtocol = DeviceSupportChecker()) {
            self.delegatedAuthenticationService = delegatedAuthenticationService
            self.deviceSupportCheckerService = deviceSupportCheckerService
            self.presenter = presenter
            super.init(context: context, service: service, appearanceConfiguration: appearanceConfiguration)
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
    
        private func addSDKOutputIfNeeded(toFingerprintResult fingerprintResult: String,
                                          _ fingerprintAction: ThreeDS2FingerprintAction,
                                          completionHandler: @escaping (Result<String, Error>) -> Void) {
            do {
                let token = try Coder.decodeBase64(fingerprintAction.fingerprintToken) as ThreeDS2Component.FingerprintToken
                let fingerprintResult: ThreeDS2Component.Fingerprint = try Coder.decodeBase64(fingerprintResult)
                performDelegatedAuthentication(token) { [weak self] result in
                    guard let self else { return }
                    self.delegatedAuthenticationState.isDeviceRegistrationFlow = result.successResult == nil
                    guard let fingerprintResult = self.createFingerPrintResult(authenticationSDKOutput: result.successResult?.sdkOutput,
                                                                               fingerprintResult: fingerprintResult,
                                                                               deleteDelegatedAuthenticationCredential: result.successResult?.deleteDelegatedAuthenticationCredential,
                                                                               completionHandler: completionHandler) else { return }
                    completionHandler(.success(fingerprintResult))
                }
            } catch {
                didFail(with: error, completionHandler: completionHandler)
            }
        
        }
        
        private func createFingerPrintResult<R>(authenticationSDKOutput: String?,
                                                fingerprintResult: ThreeDS2Component.Fingerprint,
                                                deleteDelegatedAuthenticationCredential: Bool?,
                                                completionHandler: @escaping (Result<R, Error>) -> Void) -> String? {
            do {
                let fingerprintResult = fingerprintResult.withDelegatedAuthenticationSDKOutput(
                    delegatedAuthenticationSDKOutput: authenticationSDKOutput,
                    deleteDelegatedAuthenticationCredential: deleteDelegatedAuthenticationCredential
                )
                let encodedFingerprintResult = try Coder.encodeBase64(fingerprintResult)
                return encodedFingerprintResult
            } catch {
                didFail(with: error, completionHandler: completionHandler)
            }
            return nil
        }
    
        // MARK: - Delegated Authentication

        private typealias DAPayload = (sdkOutput: String, deleteDelegatedAuthenticationCredential: Bool?) // TODO: Robert: Maybe better replace the tuple with a type for easier reading.
        
        /// This method checks;
        /// 1. if DA has been registered on the device
        /// 2. shows an approval screen if it has been registered
        /// else calls the completion with a failure.
        private func performDelegatedAuthentication(_ fingerprintToken: ThreeDS2Component.FingerprintToken,
                                                    completion: @escaping (Result<DAPayload, DelegateAuthenticationError>) -> Void) {
            guard let delegatedAuthenticationInput = fingerprintToken.delegatedAuthenticationSDKInput else {
                completion(.failure(.authenticationFailed(cause: ThreeDS2PlusDACoreActionError.sdkInputNotAvailableForApproval)))
                return
            }
            
            isDeviceRegisteredForDelegatedAuthentication(
                delegatedAuthenticationInput: delegatedAuthenticationInput,
                registeredHandler: { [weak self] in
                    guard let self else { return }
                    self.showApprovalScreen(delegatedAuthenticationInput: delegatedAuthenticationInput,
                                            completion: completion)
                },
                notRegisteredHandler: {
                    completion(.failure(.authenticationFailed(cause: $0)))
                }
            )
        }
        
        // MARK: Delegated Authentication Approval

        private struct DelegatedAuthenticationPayload {
            let delegatedAuthenticationOutput: String
            let delete: Bool?
        }
        
        private func showApprovalScreen(delegatedAuthenticationInput: String,
                                        completion: @escaping (Result<DAPayload, DelegateAuthenticationError>) -> Void) {
            presenter.showApprovalScreen(
                component: self,
                approveAuthenticationHandler: { [weak self] in
                    guard let self else { return }
                    self.executeDAAuthenticate(delegatedAuthenticationInput: delegatedAuthenticationInput,
                                               authenticatedHandler: {
                                                   completion(.success(($0, nil)))
                                               },
                                               failedAuthenticationHandler: {
                                                   completion(.failure(.authenticationFailed(cause: $0)))
                                               })
                },
                fallbackHandler: {
                    completion(.failure(.authenticationFailed(cause: ThreeDS2PlusDACoreActionError.noConsentForApproval)))
                },
                removeCredentialsHandler: { [weak self] in
                    guard let self else { return }
                    self.executeDAAuthenticate(delegatedAuthenticationInput: delegatedAuthenticationInput,
                                               authenticatedHandler: { [weak self] sdkOutput in
                                                   completion(.success((sdkOutput, true)))
                                               },
                                               failedAuthenticationHandler: { error in
                                                   completion(.failure(.authenticationFailed(cause: error)))
                                               })
                }
            )
        }

        private func executeDAAuthenticate(delegatedAuthenticationInput: String,
                                           authenticatedHandler: @escaping (String) -> Void,
                                           failedAuthenticationHandler: @escaping (Error) -> Void) {
            delegatedAuthenticationService.authenticate(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case let .success(sdkOutput):
                    authenticatedHandler(sdkOutput)
                case let .failure(error):
                    failedAuthenticationHandler(error)
                }
            }
        }
        
        private func isDeviceRegisteredForDelegatedAuthentication(delegatedAuthenticationInput: String,
                                                                  registeredHandler: @escaping () -> Void,
                                                                  notRegisteredHandler: @escaping (Error) -> Void) {
            delegatedAuthenticationService.isDeviceRegistered(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case let .failure(error):
                    notRegisteredHandler(error)
                case let .success(isRegistered):
                    if isRegistered {
                        registeredHandler()
                    } else {
                        notRegisteredHandler(ThreeDS2PlusDACoreActionError.deviceIsNotRegistered)
                    }
                }
            }
        }
                
        // MARK: Delegated Authentication Registration

        internal var shouldShowRegistrationScreen: Bool {
            delegatedAuthenticationState.isDeviceRegistrationFlow
                && presenter.userInput.canShowRegistration
                && deviceSupportCheckerService.isDeviceSupported
        }
                        
        internal func performDelegatedRegistration(_ sdkInput: String,
                                                   completion: @escaping (Result<String, Error>) -> Void) {
            delegatedAuthenticationService.register(withRegistrationInput: sdkInput) { result in
                switch result {
                case let .success(sdkOutput):
                    completion(.success(sdkOutput))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
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
                
                guard let sdkInput = token.delegatedAuthenticationSDKInput else {
                    completionHandler(.success(challengeResult))
                    return
                }
                if shouldShowRegistrationScreen {
                    showDelegatedAuthenticationRegistration(sdkInput: sdkInput,
                                                            challengeResult: challengeResult,
                                                            completionHandler: completionHandler)
                } else {
                    completionHandler(.success(challengeResult))
                }
            } catch {
                return didFail(with: error, completionHandler: completionHandler)
            }
        }
        
        private func showDelegatedAuthenticationRegistration(sdkInput: String,
                                                             challengeResult: ThreeDSResult,
                                                             completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
            presenter.showRegistrationScreen(component: self,
                                             registerDelegatedAuthenticationHandler: { [weak self] in
                                                 guard let self else { return }
                                                 self.performDelegatedRegistration(sdkInput) { [weak self] result in
                                                     self?.deliver(challengeResult: challengeResult,
                                                                   delegatedAuthenticationSDKOutput: result.successResult,
                                                                   completionHandler: completionHandler)
                                                 }
                                             },
                                             fallbackHandler: {
                                                 completionHandler(.success(challengeResult))
                                             })
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
                  appleTeamIdentifier: appleTeamIdentifier)
        }
    }

#endif
