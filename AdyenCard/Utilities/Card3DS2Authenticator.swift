//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

/// Performs a 3D-Secure 2.0 authentication for card payments.
public final class Card3DS2Authenticator {
    
    /// Initializes the authenticator.
    ///
    /// - Parameter appearanceConfiguration: The appearance configuration used to customize the challenge flow.
    public init(appearanceConfiguration: ADYAppearanceConfiguration? = nil) {
        self.appearanceConfiguration = appearanceConfiguration
    }
    
    /// Creates a fingerprint using a fingerprint token received from the Checkout API.
    ///
    /// - Parameters:
    ///   - token: The fingerprint token received from the Checkout API.
    ///   - completion: A completion handler that will be invoked with the fingerprint on success.
    public func createFingerprint(usingToken token: String, completion: @escaping Completion<Result<String>>) {
        do {
            let decodedFingerprintToken = try Base64Coder.decode(FingerprintToken.self, from: token)
            
            createFingerprint(forDirectoryServerIdentifier: decodedFingerprintToken.directoryServerIdentifier,
                              directoryServerPublicKey: decodedFingerprintToken.directoryServerPublicKey,
                              completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Creates a fingerprint using a directory server identifier and public key.
    ///
    /// - Parameters:
    ///   - directoryServerIdentifier: The directory server identifier.
    ///   - directoryServerPublicKey: The directory server public key.
    ///   - completion: A completion handler that will be invoked with the fingerprint on success.
    public func createFingerprint(forDirectoryServerIdentifier directoryServerIdentifier: String, directoryServerPublicKey: String, completion: @escaping Completion<Result<String>>) {
        let serviceParameters = ADYServiceParameters()
        serviceParameters.directoryServerIdentifier = directoryServerIdentifier
        serviceParameters.directoryServerPublicKey = directoryServerPublicKey
        
        ADYService.service(with: serviceParameters, appearanceConfiguration: appearanceConfiguration) { service in
            do {
                let transaction = try service.transaction(withMessageVersion: nil)
                self.transaction = transaction
                
                let fingerprint = try Fingerprint(authenticationRequestParameters: transaction.authenticationRequestParameters)
                let encodedFingerprint = try Base64Coder.encode(fingerprint)
                
                completion(.success(encodedFingerprint))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Presents a challenge.
    ///
    /// - Parameters:
    ///   - token: The challenge token, as received from the Checkout API.
    ///   - completion: A closure to invoke with the result of the challenge upon completion.
    public func presentChallenge(usingToken token: String, timeout: TimeInterval? = nil, completion: @escaping Completion<Result<ChallengeResult>>) {
        guard let transaction = transaction else {
            completion(.failure(Error.missingTransaction))
            
            return
        }
        
        // Decode challenge token.
        let decodedChallengeToken: ChallengeToken
        do {
            decodedChallengeToken = try Base64Coder.decode(ChallengeToken.self, from: token)
        } catch {
            completion(.failure(error))
            
            return
        }
        
        // Perform challenge.
        let challengeParameters = ADYChallengeParameters(from: decodedChallengeToken)
        transaction.performChallenge(with: challengeParameters, timeout: timeout ?? ADYTransactionDefaultChallengeTimeout) { result, error in
            if let result = result {
                do {
                    let challengeResult = try ChallengeResult(from: result)
                    completion(.success(challengeResult))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
            
            self.transaction = nil
        }
    }
    
    // MARK: - Adyen3DS2
    
    private let appearanceConfiguration: ADYAppearanceConfiguration?
    private var transaction: ADYTransaction?
    
}

// MARK: - Card3DS2Authenticator.ChallengeResult

public extension Card3DS2Authenticator {
    
    /// Contains the result of a challenge.
    struct ChallengeResult {
        
        /// A boolean value indicating whether the shopper was authenticated.
        public let isAuthenticated: Bool
        
        /// The payload to submit to verify the authentication.
        public let payload: String
        
        fileprivate init(from challengeResult: ADYChallengeResult) throws {
            let payloadData = try JSONSerialization.data(withJSONObject: ["transStatus": challengeResult.transactionStatus],
                                                         options: [])
            
            self.isAuthenticated = challengeResult.transactionStatus == "Y"
            self.payload = payloadData.base64EncodedString()
        }
        
    }
    
}

// MARK: - Card3DS2Authenticator.Fingerprint

fileprivate extension Card3DS2Authenticator {
    
    struct Fingerprint: Encodable {
        
        fileprivate let deviceInformation: String
        fileprivate let sdkEphemeralPublicKey: EphemeralPublicKey
        fileprivate let sdkReferenceNumber: String
        fileprivate let sdkApplicationIdentifier: String
        fileprivate let sdkTransactionIdentifier: String
        
        fileprivate init(authenticationRequestParameters: ADYAuthenticationRequestParameters) throws {
            let sdkEphemeralPublicKeyData = Data(authenticationRequestParameters.sdkEphemeralPublicKey.utf8)
            let sdkEphemeralPublicKey = try JSONDecoder().decode(EphemeralPublicKey.self, from: sdkEphemeralPublicKeyData)
            
            self.deviceInformation = authenticationRequestParameters.deviceInformation
            self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
            self.sdkReferenceNumber = authenticationRequestParameters.sdkReferenceNumber
            self.sdkApplicationIdentifier = authenticationRequestParameters.sdkApplicationIdentifier
            self.sdkTransactionIdentifier = authenticationRequestParameters.sdkTransactionIdentifier
        }
        
        private enum CodingKeys: String, CodingKey {
            case deviceInformation = "sdkEncData"
            case sdkEphemeralPublicKey = "sdkEphemPubKey"
            case sdkReferenceNumber
            case sdkApplicationIdentifier = "sdkAppID"
            case sdkTransactionIdentifier = "sdkTransID"
        }
        
    }
    
}

// MARK: - Card3DS2Authenticator.Fingerprint.EphemeralPublicKey

fileprivate extension Card3DS2Authenticator {
    
    struct EphemeralPublicKey: Codable {
        
        fileprivate let keyType: String
        fileprivate let curve: String
        fileprivate let x: String // swiftlint:disable:this identifier_name
        fileprivate let y: String // swiftlint:disable:this identifier_name
        
        private enum CodingKeys: String, CodingKey {
            case keyType = "kty"
            case curve = "crv"
            case x // swiftlint:disable:this identifier_name
            case y // swiftlint:disable:this identifier_name
        }
        
    }
    
}

// MARK: - Card3DS2Authenticator.Error

fileprivate extension Card3DS2Authenticator {
    
    enum Error: Swift.Error {
        case missingTransaction
    }
    
}

// MARK: - Card3DS2Authenticator.Base64JSONCoder

fileprivate extension Card3DS2Authenticator {
    
    enum Base64Coder {
        
        fileprivate static func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T {
            guard let data = Data(base64Encoded: string) else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "Given string is not valid base64.")
                
                throw DecodingError.dataCorrupted(context)
            }
            
            return try JSONDecoder().decode(type, from: data)
        }
        
        fileprivate static func encode<T: Encodable>(_ value: T) throws -> String {
            let data = try JSONEncoder().encode(value)
            
            return data.base64EncodedString()
        }
        
    }
    
}
