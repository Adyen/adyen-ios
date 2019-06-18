//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

/// Handles the 3D Secure 2 fingerprint and challenge.
public final class ThreeDS2Component: ActionComponent {
    
    /// The appearance configuration of the 3D Secure 2 challenge UI.
    public let appearanceConfiguration = ADYAppearanceConfiguration()
    
    /// The delegate of the component.
    public weak var delegate: ActionComponentDelegate?
    
    /// Initializes the 3D Secure 2 component.
    public init() {}
    
    // MARK: - Fingerprint
    
    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter action: The fingerprint action as received from the Checkout API.
    public func handle(_ action: ThreeDS2FingerprintAction) {
        Analytics.sendEvent(component: fingerprintEventName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        do {
            let token = try Coder.decodeBase64(action.token) as FingerprintToken
            
            let serviceParameters = ADYServiceParameters()
            serviceParameters.directoryServerIdentifier = token.directoryServerIdentifier
            serviceParameters.directoryServerPublicKey = token.directoryServerPublicKey
            
            ADYService.service(with: serviceParameters, appearanceConfiguration: appearanceConfiguration) { service in
                self.createFingerprint(using: service, paymentData: action.paymentData)
            }
        } catch {
            didFail(with: error)
        }
    }
    
    private func createFingerprint(using service: ADYService, paymentData: String) {
        do {
            let transaction = try service.transaction(withMessageVersion: nil)
            self.transaction = transaction
            
            let fingerprint = try Fingerprint(authenticationRequestParameters: transaction.authenticationRequestParameters)
            let encodedFingerprint = try Coder.encodeBase64(fingerprint)
            let additionalDetails = ThreeDS2Details.fingerprint(encodedFingerprint)
            
            self.delegate?.didProvide(ActionComponentData(details: additionalDetails, paymentData: paymentData), from: self)
        } catch {
            didFail(with: error)
        }
    }
    
    // MARK: - Challenge
    
    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter action: The challenge action as received from the Checkout API.
    public func handle(_ action: ThreeDS2ChallengeAction) {
        guard let transaction = transaction else { return }
        
        Analytics.sendEvent(component: challengeEventName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        do {
            let token = try Coder.decodeBase64(action.token) as ChallengeToken
            let challengeParameters = ADYChallengeParameters(from: token)
            transaction.performChallenge(with: challengeParameters) { result, error in
                if let error = error {
                    self.delegate?.didFail(with: error, from: self)
                } else if let result = result {
                    self.handle(result, paymentData: action.paymentData)
                }
            }
        } catch {
            didFail(with: error)
        }
    }
    
    private func handle(_ sdkChallengeResult: ADYChallengeResult, paymentData: String) {
        do {
            let challengeResult = try ChallengeResult(from: sdkChallengeResult)
            didFinish(with: challengeResult, paymentData: paymentData)
        } catch {
            didFail(with: error)
        }
    }
    
    // MARK: - Private
    
    private let fingerprintEventName = "3ds2fingerprint"
    private let challengeEventName = "3ds2challenge"
    
    private var transaction: ADYTransaction?
    
    private func didFinish(with challengeResult: ChallengeResult, paymentData: String) {
        transaction = nil
        
        let additionalDetails = ThreeDS2Details.challengeResult(challengeResult)
        delegate?.didProvide(ActionComponentData(details: additionalDetails, paymentData: paymentData), from: self)
    }
    
    private func didFail(with error: Error) {
        transaction = nil
        
        delegate?.didFail(with: error, from: self)
    }
    
}
