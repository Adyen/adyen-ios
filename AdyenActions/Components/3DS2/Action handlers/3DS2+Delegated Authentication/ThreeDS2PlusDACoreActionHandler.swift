//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal typealias VoidHandler = () -> Void

// swiftlint:disable file_length

#if canImport(AdyenAuthentication)
    @_spi(AdyenInternal) import Adyen
    import Adyen3DS2
    import AdyenAuthentication
    import Foundation
    import UIKit
    
    /// Handles the 3D Secure 2 fingerprint and challenge actions separately + Delegated Authentication.
    @available(iOS 16.0, *)
    // swiftlint:disable:next type_body_length
    internal class ThreeDS2PlusDACoreActionHandler: ThreeDS2CoreActionHandler {
        internal var delegatedAuthenticationState: DelegatedAuthenticationState = .init()
        
        internal struct DelegatedAuthenticationState {
            internal var attemptRegistration: Bool = false
        }
        
        private let delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication
        private var delegatedAuthenticationService: AuthenticationServiceProtocol?
        private let deviceSupportCheckerService: AdyenAuthentication.DeviceSupportCheckerProtocol
        private var presenter: ThreeDS2PlusDAScreenPresenterProtocol
        
        private enum Constants {
            static let consecutiveCancellationTolerance = 2
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
        ) {
            self.init(
                context: context,
                presenter: ThreeDS2PlusDAScreenPresenter(
                    style: delegatedAuthenticationConfiguration.delegatedAuthenticationComponentStyle,
                    localizedParameters: delegatedAuthenticationConfiguration.localizationParameters,
                    context: context
                ),
                appearanceConfiguration: appearanceConfiguration,
                style: delegatedAuthenticationConfiguration.delegatedAuthenticationComponentStyle,
                delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
            )
        }
        
        /// Initializes the 3D Secure 2 action handler.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter service: The 3DS2 Service.
        /// - Parameter presenter: The presenter
        /// - Parameter appearanceConfiguration: The appearance configuration.
        /// - Parameter style: The delegate authentication component style.
        /// - Parameter delegatedAuthenticationConfiguration: The delegate authentication configuration.
        /// - Parameter delegatedAuthenticationService: The Delegated Authentication service.
        internal init(
            context: AdyenContext,
            service: AnyADYService = ADYServiceAdapter(),
            presenter: ThreeDS2PlusDAScreenPresenterProtocol,
            appearanceConfiguration: ADYAppearanceConfiguration = .init(),
            style: DelegatedAuthenticationComponentStyle = .init(),
            delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication,
            delegatedAuthenticationService: AuthenticationServiceProtocol? = nil,
            deviceSupportCheckerService: AdyenAuthentication.DeviceSupportCheckerProtocol = DeviceSupportChecker()
        ) {
            self.delegatedAuthenticationConfiguration = delegatedAuthenticationConfiguration
            self.deviceSupportCheckerService = deviceSupportCheckerService
            self.presenter = presenter
            self.delegatedAuthenticationService = delegatedAuthenticationService
            super.init(context: context, service: service, appearanceConfiguration: appearanceConfiguration)
            self.presenter.presentationDelegate = self
        }
        
        // MARK: - Fingerprint
        
        /// Handles the 3D Secure 2 fingerprint action.
        ///
        /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
        /// - Parameter event: The Analytics event.
        /// - Parameter completionHandler: The completion closure.
        override internal func handle(
            _ fingerprintAction: ThreeDS2FingerprintAction,
            event: Analytics.Event,
            completionHandler: @escaping (Result<String, Error>) -> Void
        ) {
            super.handle(fingerprintAction, event: event) { [weak self] result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(threeDSFingerprint):
                    guard let self,
                          let payloadForDA = self.daPayload(fingerprintAction) else {
                        // If there is no payload for delegated authentication approval, continue with the 3ds flow.
                        self?.delegatedAuthenticationState.attemptRegistration = true
                        completionHandler(.success(threeDSFingerprint))
                        return
                    }
                    
                    self.startApprovalFlow(
                        payloadForDA.sdkInput,
                        cardType: payloadForDA.cardType,
                        cardNumber: payloadForDA.cardNumber,
                        amount: payloadForDA.amount
                    ) { [weak self] result in
                        guard let self else { return }
                        
                        switch result {
                        case let .success(approvalResponse):
                            do {
                                let threeDSFingerPrintWithDAPayload = try self.modifyFingerPrint(
                                    with: approvalResponse.daOutput,
                                    threeDSFingerPrint: threeDSFingerprint,
                                    deleteDelegatedAuthenticationCredential: approvalResponse.delete
                                )
                                
                                completionHandler(.success(threeDSFingerPrintWithDAPayload))
                            } catch {
                                // If there is any failure in the DA handling we always default to 3ds2.
                                completionHandler(.success(threeDSFingerprint))
                            }
                        case .failure:
                            // If there is any failure in the DA handling we always default to 3ds2.
                            completionHandler(.success(threeDSFingerprint))
                        }
                    }
                }
            }
        }
                
        private struct ApprovalPayload {
            let sdkInput: String
            let cardNumber: String?
            let cardType: CardType?
            let amount: Amount?
        }
        
        private func daPayload(
            _ fingerprintAction: ThreeDS2FingerprintAction
        ) -> ApprovalPayload? {
            guard let token: ThreeDS2Component.FingerprintToken = try? AdyenCoder.decodeBase64(fingerprintAction.fingerprintToken),
                  let sdkInput = token.delegatedAuthenticationSDKInput else {
                return nil
            }
            
            return ApprovalPayload(
                sdkInput: sdkInput,
                cardNumber: securedCardNumber(lastFour: token.paymentInfo?.lastFour),
                cardType: token.paymentInfo?.cardType,
                amount: token.paymentInfo?.amount ?? context.payment?.amount
            )
        }
        
        /// Adds the authenticationSDK output into the fingerprint result to approve the transaction/delete the credential in the backend.
        private func modifyFingerPrint(
            with authenticationSDKOutput: String?,
            threeDSFingerPrint: String,
            deleteDelegatedAuthenticationCredential: Bool?
        ) throws -> String {
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
            cardType: CardType?,
            cardNumber: String?,
            amount: Amount?,
            completion: @escaping (Result<(daOutput: String, delete: Bool?), ApprovalFlowError>) -> Void
        ) {
            isDeviceRegistered(delegatedAuthenticationInput: delegatedAuthenticationInput) { [weak self] registered in
                guard let self else { return }
                if registered {
                    self.showApprovalScreen(
                        delegatedAuthenticationInput: delegatedAuthenticationInput,
                        cardType: cardType,
                        cardNumber: cardNumber,
                        amount: amount,
                        completion: completion
                    )
                } else {
                    // setting the state to attempt the registration flow.
                    self.delegatedAuthenticationState.attemptRegistration = true
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
            cardType: CardType?,
            cardNumber: String?,
            amount: Amount?,
            completion: @escaping (Result<(daOutput: String, delete: Bool?), ApprovalFlowError>
            ) -> Void
        ) {
            presenter.showApprovalScreen(
                component: self,
                cardDetails: (cardNumber, cardType),
                amount: amount,
                approveAuthenticationHandler: { [weak self] in
                    guard let self else { return }
                    self.userApprovedTransaction(
                        delegatedAuthenticationInput: delegatedAuthenticationInput,
                        cardNumber: cardNumber,
                        completion: completion
                    )
                },
                fallbackHandler: {
                    completion(.failure(.fallbackTo3ds))
                },
                removeCredentialsHandler: { [weak self] in
                    guard let self else { return }
                    self.userChoseToRemoveCredentials(
                        delegatedAuthenticationInput: delegatedAuthenticationInput,
                        cardNumber: cardNumber,
                        completion: completion
                    )
                }
            )
        }
        
        /// Call this when user approves a transaction in the UI
        /// 1. Authenticates using the sdk.
        /// 2. If failure then show an error.
        private func userApprovedTransaction(
            delegatedAuthenticationInput: String,
            cardNumber: String?,
            completion: @escaping (Result<(daOutput: String, delete: Bool?), ApprovalFlowError>) -> Void
        ) {
            authenticate(
                delegatedAuthenticationInput: delegatedAuthenticationInput,
                cardNumber: cardNumber,
                authenticatedHandler: {
                    completion(.success((daOutput: $0, delete: nil)))
                },
                failedAuthenticationHandler: { [weak self] error in
                    guard let self else { return }
                    
                    if case let AdyenAuthenticationError.consecutiveCancellationOnApproval(count) = error,
                       count >= Constants.consecutiveCancellationTolerance {
                        try? service(cardNumber: nil).reset()
                    }
                    
                    self.presenter.showAuthenticationError(
                        component: self,
                        handler: {
                            completion(.failure(.authenticationServiceFailed(underlyingError: error)))
                        },
                        troubleshootingHandler: { [weak self] in
                            try? self?.service(cardNumber: cardNumber).reset()
                            completion(.failure(.authenticationServiceFailed(underlyingError: error)))
                        }
                    )
                }
            )
        }

        /// Call this when user approves a transaction in the UI
        /// 1. Authenticates using the authentication service.
        /// 2. show delete confirmation
        private func userChoseToRemoveCredentials(
            delegatedAuthenticationInput: String,
            cardNumber: String?,
            completion: @escaping (Result<(daOutput: String, delete: Bool?), ApprovalFlowError>) -> Void
        ) {
            authenticate(
                delegatedAuthenticationInput: delegatedAuthenticationInput,
                cardNumber: cardNumber,
                authenticatedHandler: { [weak self] sdkOutput in
                    guard let self else { return }
                    self.presenter.showDeletionConfirmation(component: self) {
                        self.delegatedAuthenticationState.attemptRegistration = false
                        completion(.success((daOutput: sdkOutput, delete: true)))
                    }
                },
                failedAuthenticationHandler: { error in
                    self.delegatedAuthenticationState.attemptRegistration = false
                    completion(.failure(.removeCredentialServiceError(underlyingError: error)))
                }
            )
        }

        private func authenticate(
            delegatedAuthenticationInput: String,
            cardNumber: String?,
            authenticatedHandler: @escaping (String) -> Void,
            failedAuthenticationHandler: @escaping (Error) -> Void
        ) {
            let service: AuthenticationServiceProtocol = service(cardNumber: cardNumber)

            service.authenticate(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case let .success(sdkOutput):
                    authenticatedHandler(sdkOutput)
                case let .failure(error):
                    failedAuthenticationHandler(error)
                }
            }
        }
        
        private func isDeviceRegistered(
            delegatedAuthenticationInput: String,
            handler: @escaping (Bool) -> Void
        ) {
            
            let service: AuthenticationServiceProtocol = service(cardNumber: nil)
            
            service.isDeviceRegistered(withAuthenticationInput: delegatedAuthenticationInput) { result in
                switch result {
                case .failure:
                    // If there is an error then we assume that the device is not registered and we try registration.
                    // Improvement: we could alternatively check the individual errors from AuthenticationSDK
                    // and based on which decide if we would like to call out if it is registered or not.
                    handler(false)
                case let .success(isRegistered):
                    handler(isRegistered)
                }
            }
        }
        
        // MARK: Delegated Authentication Registration
        
        internal func register(
            delegatedAuthenticationInput: String,
            cardNumber: String?,
            completion: @escaping (Result<String, Error>) -> Void
        ) {
            
            let service: AuthenticationServiceProtocol = service(cardNumber: cardNumber)
            
            service.register(withRegistrationInput: delegatedAuthenticationInput) { result in
                switch result {
                case let .success(sdkOutput):
                    completion(.success(sdkOutput))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
        
        internal func service(cardNumber: String?) -> AuthenticationServiceProtocol {
            if let delegatedAuthenticationService {
                return delegatedAuthenticationService
            }
            
            return AdyenAuthentication.AuthenticationService(
                passKeyConfiguration: .init(
                    relyingPartyIdentifier: delegatedAuthenticationConfiguration.relyingPartyIdentifier,
                    displayName: cardNumber ?? Bundle.main.displayName,
                    consecutiveApprovalCancellationsLimit: Constants.consecutiveCancellationTolerance
                )
            )

        }
        
        // MARK: - Challenge
        
        /// Handles the 3D Secure 2 challenge action.
        ///
        /// - Parameter challengeAction: The challenge action as received from the Checkout API.
        /// - Parameter event: The Analytics event.
        /// - Parameter completionHandler: The completion closure.
        override internal func handle(
            _ challengeAction: ThreeDS2ChallengeAction,
            event: Analytics.Event,
            completionHandler: @escaping (Result<ThreeDSResult, Error>) -> Void
        ) {
            super.handle(challengeAction, event: event) { [weak self] result in
                switch result {
                case let .failure(error):
                    completionHandler(.failure(error))
                case let .success(threeDSResult):
                    guard let self,
                          self.delegatedAuthenticationState.attemptRegistration,
                          self.deviceSupportCheckerService.isDeviceSupported,
                          let registrationPayload = self.daPayload(challengeAction) else {
                        // If there is no payload for delegated authentication approval, continue with the 3ds flow.
                        completionHandler(.success(threeDSResult))
                        return
                    }
                    
                    self.startRegistrationFlow(
                        delegatedAuthenticationInput: registrationPayload.sdkInput,
                        cardNumber: registrationPayload.cardNumber,
                        cardType: registrationPayload.cardType
                    ) { result in
                        switch result {
                        case let .success(registrationSDKOutput):
                            do {
                                let threeDSResultWithRegistrationPayload = try threeDSResult.withDelegatedAuthenticationSDKOutput(
                                    delegatedAuthenticationSDKOutput: registrationSDKOutput
                                )
                                completionHandler(.success(threeDSResultWithRegistrationPayload))
                                
                            } catch {
                                completionHandler(.success(threeDSResult))
                            }
                            
                        case .failure:
                            completionHandler(.success(threeDSResult))
                        }
                    }
                }
            }
        }
        
        private enum RegistrationFlowError: Error {
            case registrationServiceError(underlyingError: Error)
            case userOptedOutOfRegistration
        }
        
        private func startRegistrationFlow(
            delegatedAuthenticationInput: String,
            cardNumber: String?,
            cardType: CardType?,
            completionHandler: @escaping (Result<String, RegistrationFlowError>) -> Void
        ) {
            presenter.showRegistrationScreen(
                component: self,
                cardDetails: (cardNumber, cardType),
                registerDelegatedAuthenticationHandler: { [weak self] in
                    guard let self else { return }
                    self.userChoseToRegister(
                        delegatedAuthenticationInput: delegatedAuthenticationInput,
                        cardNumber: cardNumber,
                        completionHandler: completionHandler
                    )
                },
                fallbackHandler: {
                    // Improvement: Is it possible to track this through some event?
                    completionHandler(.failure(.userOptedOutOfRegistration))
                }
            )
        }
        
        private func userChoseToRegister(
            delegatedAuthenticationInput: String,
            cardNumber: String?,
            completionHandler: @escaping (Result<String, RegistrationFlowError>) -> Void
        ) {
            register(
                delegatedAuthenticationInput: delegatedAuthenticationInput,
                cardNumber: cardNumber
            ) { [weak self] result in
                switch result {
                case let .success(success):
                    completionHandler(.success(success))
                case let .failure(failure):
                    guard let self else { return }
                    self.presenter.showRegistrationError(component: self) {
                        completionHandler(.failure(.registrationServiceError(underlyingError: failure)))
                    }
                }
            }
        }

        private struct RegistrationPayload {
            let sdkInput: String
            let cardNumber: String?
            let cardType: CardType?
        }
        
        private func daPayload(_ challengeAction: ThreeDS2ChallengeAction) -> RegistrationPayload? {
            guard let token: ThreeDS2Component.ChallengeToken = try? AdyenCoder.decodeBase64(challengeAction.challengeToken),
                  let sdkInput = token.delegatedAuthenticationSDKInput else {
                return nil
            }
            return RegistrationPayload(
                sdkInput: sdkInput,
                cardNumber: securedCardNumber(lastFour: token.paymentInfo?.lastFour),
                cardType: token.paymentInfo?.cardType
            )
        }
        
        private func securedCardNumber(lastFour: String?) -> String? {
            guard let lastFour else {
                return nil
            }
            return String.Adyen.securedString + lastFour
        }
    }

    private extension Bundle {
        // Name of the app - title under the icon.
        var displayName: String {
            object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        }
    }

#endif

// swiftlint:enable file_length
