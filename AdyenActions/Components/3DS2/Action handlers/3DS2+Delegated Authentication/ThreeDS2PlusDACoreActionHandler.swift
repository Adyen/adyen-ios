//
// Copyright (c) 2024 Adyen N.V.
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
    @available(iOS 16.0, *)
    internal class ThreeDS2PlusDACoreActionHandler: ThreeDS2CoreActionHandler {
    
        internal var delegatedAuthenticationState: DelegatedAuthenticationState = .init()
    
        internal struct DelegatedAuthenticationState {
            internal var isDeviceRegistrationFlow: Bool = false
        }
    
        private let delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication
        private var delegatedAuthenticationService: AuthenticationServiceProtocol?
        private let deviceSupportCheckerService: AdyenAuthentication.DeviceSupportCheckerProtocol
        private var presenter: ThreeDS2PlusDAScreenPresenterProtocol
            
        /// Errors during the Delegated authentication flow
        private enum ThreeDS2PlusDACoreActionError: Error {
            /// When the backend doesn't support delegated authentication, so the threeDSToken doesn't contain the `sdkInput` parameter
            case sdkInputNotAvailableForApproval
            /// When the device is not registered for delegated authentication.
            case deviceIsNotRegistered
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
            delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication
        ) throws {
            self.init(
                context: context,
                presenter: ThreeDS2PlusDAScreenPresenter(style: .init(),
                                                         localizedParameters: delegatedAuthenticationConfiguration.localizationParameters),
                appearanceConfiguration: appearanceConfiguration,
                style: delegatedAuthenticationConfiguration.delegatedAuthenticationComponentStyle,
                delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
            )
            
        }
    
        /// Initializes the 3D Secure 2 action handler.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter service: The 3DS2 Service.
        /// - Parameter appearanceConfiguration: The appearance configuration.
        /// - Parameter style: The delegate authentication component style.
        /// - Parameter delegatedAuthenticationConfiguration: The delegate authentication configuration.
        /// - Parameter delegatedAuthenticationService: The Delegated Authentication service.
        /// - Parameter presentationDelegate: Presentation delegate
        internal init(context: AdyenContext,
                      service: AnyADYService = ADYServiceAdapter(),
                      presenter: ThreeDS2PlusDAScreenPresenterProtocol,
                      appearanceConfiguration: ADYAppearanceConfiguration = .init(),
                      style: DelegatedAuthenticationComponentStyle = .init(),
                      delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication,
                      delegatedAuthenticationService: AuthenticationServiceProtocol? = nil,
                      deviceSupportCheckerService: AdyenAuthentication.DeviceSupportCheckerProtocol = DeviceSupportChecker()) {
            self.delegatedAuthenticationConfiguration = delegatedAuthenticationConfiguration
            self.deviceSupportCheckerService = deviceSupportCheckerService
            self.presenter = presenter
            super.init(context: context, service: service, appearanceConfiguration: appearanceConfiguration)
            self.presenter.presentationDelegate = self
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
            
            let completion: (Result<String, Error>) -> Void = { [weak self] result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(threeDSFingerprint):
                    guard let self,
                          let payloadForDA = daPayload(fingerprintAction: fingerprintAction) else {
                        // If there is no payload for delegated authentication approval, continue with the 3ds flow.
                        completionHandler(.success(threeDSFingerprint))
                        return
                    }
                    
                    startApprovalFlow(payloadForDA) { [weak self] result in
                        guard let self else { return }
                        
                        switch result {
                        case let .success(approvalResponse):
                            do {
                                let threeDSFingerPrintWithDAPayload = try modifyFingerPrint(
                                    with: approvalResponse.daOutput,
                                    threeDSFingerPrint: threeDSFingerprint,
                                    deleteDelegatedAuthenticationCredential: approvalResponse.delete
                                )
                                
                                completionHandler(.success(threeDSFingerPrintWithDAPayload))
                            } catch {
                                completionHandler(.success(threeDSFingerprint))
                            }
                        case .failure:
                            // If there is any failure in the DA handling we always default to 3ds2 authentication.
                            completionHandler(.success(threeDSFingerprint))
                        }
                    }
                }
            }
            
            super.handle(fingerprintAction, event: event, completionHandler: completion)
        }
        
        private func daPayload(fingerprintAction: ThreeDS2FingerprintAction) -> String? {
            guard let token = try? AdyenCoder.decodeBase64(fingerprintAction.fingerprintToken) as ThreeDS2Component.FingerprintToken else {
                return nil
            }
            return token.delegatedAuthenticationSDKInput
        }
        
        /// Adds the authenticationSDK output into the fingerprint result to approve the transaction/delete the credential in the backend.
        private func modifyFingerPrint(with authenticationSDKOutput: String?,
                                       threeDSFingerPrint: String,
                                       deleteDelegatedAuthenticationCredential: Bool?) throws -> String {
            var fingerprintResult: ThreeDS2Component.Fingerprint = try AdyenCoder.decodeBase64(threeDSFingerPrint)
            fingerprintResult = fingerprintResult.withDelegatedAuthenticationSDKOutput(
                delegatedAuthenticationSDKOutput: authenticationSDKOutput,
                deleteDelegatedAuthenticationCredential: deleteDelegatedAuthenticationCredential
            )
            let encodedFingerprintResult = try AdyenCoder.encodeBase64(fingerprintResult)
            return encodedFingerprintResult
        }
    
        // MARK: - Delegated Authentication
    
        /// This method checks;
        /// 1. if DA has been registered on the device
        /// 2. shows an approval screen if it has been registered
        /// else calls the completion with a failure.
        private func startApprovalFlow(
            _ delegatedAuthenticationInput: String,
            completion: @escaping (Result<(daOutput: String, delete: Bool?), ApprovalFlowError>) -> Void
        ) {
            isDeviceRegistered(delegatedAuthenticationInput: delegatedAuthenticationInput) { [weak self] registered in
                guard let self else { return }
                if registered {
                    showApprovalScreen(delegatedAuthenticationInput: delegatedAuthenticationInput,
                                       completion: completion)
                } else {
                    // setting the state to attempt the registration flow.
                    delegatedAuthenticationState.isDeviceRegistrationFlow = true
                    completion(.failure(.deviceIsNotRegistered))
                }
            }
        }
    
        // MARK: Delegated Authentication Approval

        private enum ApprovalFlowError: Error {
            case fallbackTo3ds
            case deviceIsNotRegistered
            case authenticationServiceFailed(underlyingError: Error)
            case removeCredentialServiceError(underlyingError: Error)
        }
        
        private func showApprovalScreen(
            delegatedAuthenticationInput: String,
            completion: @escaping (Result<(daOutput: String, delete: Bool?), ApprovalFlowError>
            ) -> Void
        ) {
            presenter.showApprovalScreen(
                component: self,
                approveAuthenticationHandler: { [weak self] in
                    guard let self else { return }
                    authenticate(delegatedAuthenticationInput: delegatedAuthenticationInput,
                                 authenticatedHandler: {
                                     completion(.success((daOutput: $0, delete: nil)))
                                 },
                                 failedAuthenticationHandler: { error in
                                     completion(.failure(.authenticationServiceFailed(underlyingError: error)))
                                 })
                },
                fallbackHandler: {
                    completion(.failure(.fallbackTo3ds))
                },
                removeCredentialsHandler: { [weak self] in
                    guard let self else { return }
                    authenticate(delegatedAuthenticationInput: delegatedAuthenticationInput,
                                 authenticatedHandler: { sdkOutput in
                                     completion(.success((daOutput: sdkOutput, delete: true)))
                                 },
                                 failedAuthenticationHandler: { error in
                                     completion(.failure(.removeCredentialServiceError(underlyingError: error)))
                                 })
                }
            )
        }
    
        private func authenticate(delegatedAuthenticationInput: String,
                                  authenticatedHandler: @escaping (String) -> Void,
                                  failedAuthenticationHandler: @escaping (Error) -> Void) {
            let service: AuthenticationServiceProtocol = if let delegatedAuthenticationService {
                delegatedAuthenticationService
            } else {
                AdyenAuthentication.AuthenticationService(
                    passKeyConfiguration: .init(relyingPartyIdentifier: delegatedAuthenticationConfiguration.relyingPartyIdentifier,
                                                displayName: "Card Number TBD 🔥")
                ) // TODO: Robert: pass the card number when it is available.
            }
            
            service.authenticate(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case let .success(sdkOutput):
                    authenticatedHandler(sdkOutput)
                case let .failure(error):
                    failedAuthenticationHandler(error)
                }
            }
        }
    
        private func isDeviceRegistered(delegatedAuthenticationInput: String,
                                        handler: @escaping (Bool) -> Void) {
            
            let service: AuthenticationServiceProtocol = if let delegatedAuthenticationService {
                delegatedAuthenticationService
            } else {
                AdyenAuthentication.AuthenticationService(
                    passKeyConfiguration: .init(
                        relyingPartyIdentifier: delegatedAuthenticationConfiguration.relyingPartyIdentifier,
                        displayName: "" // At this point the display name isn't used.
                    )
                )
            }

            service.isDeviceRegistered(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case .failure:
                    // If there is an error then we assume that the device is not registered and we try registration.
                    // Improvement: we could alternatively check the individual errors from AuthenticationSDK and based on which decide if we would like to call out if it is registered or not.
                    handler(false)
                case let .success(isRegistered):
                    handler(isRegistered)
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
            
            let service: AuthenticationServiceProtocol = if let delegatedAuthenticationService {
                delegatedAuthenticationService
            } else {
                AdyenAuthentication.AuthenticationService(
                    passKeyConfiguration: .init(
                        relyingPartyIdentifier: delegatedAuthenticationConfiguration.relyingPartyIdentifier,
                        displayName: "Card Number TBD 🔥 "
                    ) // TODO: Robert: Pass the card number that we recieve from the challenge token.
                )
            }

            service.register(withRegistrationInput: sdkInput) { result in
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
                    self?.addSDKOutputIfNeeded(toChallengeResult: challengeResult,
                                               challengeAction,
                                               completionHandler: completionHandler)
                }
            }
        }
    
        private func addSDKOutputIfNeeded(toChallengeResult challengeResult: ThreeDSResult,
                                          _ challengeAction: ThreeDS2ChallengeAction,
                                          completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void) {
            do {
                let token: ThreeDS2Component.ChallengeToken = try AdyenCoder.decodeBase64(challengeAction.challengeToken)
                guard let sdkInput = token.delegatedAuthenticationSDKInput, shouldShowRegistrationScreen else {
                    completionHandler(.success(challengeResult))
                    return
                }
                showDelegatedAuthenticationRegistration(sdkInput: sdkInput,
                                                        challengeResult: challengeResult,
                                                        completionHandler: completionHandler)
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
#endif
