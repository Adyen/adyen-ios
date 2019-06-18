//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides static methods for encrypting card information and retrieving public keys from the server.
public final class CardEncryptor {
    /// Contains the information of a card that is yet to be encrypted.
    public struct Card {
        /// The card number.
        public var number: String?
        
        /// The card's security code.
        public var securityCode: String?
        
        /// The month the card expires.
        public var expiryMonth: String?
        
        /// The year the card expires.
        public var expiryYear: String?
        
        /// :nodoc:
        public init(number: String? = nil, securityCode: String? = nil, expiryMonth: String? = nil, expiryYear: String? = nil) {
            self.number = number
            self.securityCode = securityCode
            self.expiryMonth = expiryMonth
            self.expiryYear = expiryYear
        }
        
    }
    
    /// Contains encrypted card information.
    public struct EncryptedCard {
        /// The encrypted card number.
        public let number: String?
        
        /// The card's encrypted security code.
        public let securityCode: String?
        
        /// The encrypted month the card expires.
        public let expiryMonth: String?
        
        /// The encrypted year the card expires.
        public let expiryYear: String?
        
    }
    
    /// Encrypts a card.
    ///
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: An encrypted card containing the individually encrypted fields.
    public static func encryptedCard(for card: Card, publicKey: String) -> EncryptedCard {
        let generationDate = Date()
        let number = card.encryptedNumber(publicKey: publicKey, date: generationDate)
        let expiryYear = card.encryptedExpiryYear(publicKey: publicKey, date: generationDate)
        let expiryMonth = card.encryptedExpiryMoth(publicKey: publicKey, date: generationDate)
        let securityCode = card.encryptedSecurityCode(publicKey: publicKey, date: generationDate)
        
        return EncryptedCard(number: number,
                             securityCode: securityCode,
                             expiryMonth: expiryMonth,
                             expiryYear: expiryYear)
    }
    
    /// Encrypts a card.
    ///
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - holderName: The cardholder's name.
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    /// - Returns: A string representing the encrypted card.
    public static func encryptedToken(for card: Card, holderName: String?, publicKey: String) throws -> String {
        guard let cardToken = card.encryptedToToken(publicKey: publicKey, holderName: holderName) else {
            throw Error.unknown
        }
        
        return cardToken
    }
    
    /// Requests the public encryption key from Adyen backend.
    ///
    /// - Parameters:
    ///   - token: Your public key token.
    ///   - environment: The environment to use when requesting the public key.
    ///   - completion: A closure that handles the result of the public key request.
    public static func requestPublicKey(forToken token: String, environment: Environment, completion: @escaping Completion<Result<String, Swift.Error>>) {
        guard let url = publicKeyFetchUrl(forToken: token, environment: environment) else {
            return
        }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { result in
            switch result {
            case let .success(data):
                do {
                    let response = try Coder.decode(data) as PublicKeyResponse
                    
                    DispatchQueue.main.async {
                        completion(.success(response.publicKey))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Encrypts a card.
    /// This methods encapsulates calls to `requestPublicKey(forToken:environment:completion:)`
    /// and `encryptedCard(for:publicKey:)`
    ///
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - publicKeyToken: Your public key token.
    ///   - environment: The environment to use when requesting the public key.
    ///   - completion: A closure that provides you with the encrypted card, or an error when the operation fails.
    public static func encryptedCard(for card: Card, publicKeyToken: String, environment: Environment, completion: @escaping Completion<Result<EncryptedCard, Swift.Error>>) {
        requestPublicKey(forToken: publicKeyToken, environment: environment) { result in
            switch result {
            case let .success(key):
                let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: key)
                completion(.success(encryptedCard))
                
            case let .failure(error):
                completion(.failure(error))
            }
            return
        }
    }
    
    /// Encrypts a card.
    /// This methods encapsulates calls to `requestPublicKey(forToken:environment:completion:)`
    /// and `encrypt(_:publicKey:)`
    ///
    /// - Parameters:
    ///   - card: Card containing the data to be encrypted.
    ///   - holderName: The cardholder's name.
    ///   - publicKeyToken: Your public key token.
    ///   - environment: The environment to use when requesting the public key.
    ///   - completion: A closure that provides you with a string representing the encrypted card, or an error when the operation fails.
    public static func encryptedToken(for card: Card, holderName: String?, publicKeyToken: String, environment: Environment, completion: @escaping Completion<Result<String, Swift.Error>>) {
        requestPublicKey(forToken: publicKeyToken, environment: environment) { result in
            switch result {
            case let .success(key):
                do {
                    let encryptedCardToken = try CardEncryptor.encryptedToken(for: card, holderName: holderName, publicKey: key)
                    completion(.success(encryptedCardToken))
                } catch {
                    completion(.failure(Error.unknown))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
            return
        }
    }
    
    // MARK: - Error
    
    /// Describes the error that can occur during card encryption and public key fetching.
    internal enum Error: Swift.Error {
        /// Indicates an unknown error occurred.
        case unknown
        
    }
    
    // MARK: - Private
    
    private init() {}
    
    private static func publicKeyFetchUrl(forToken token: String, environment: Environment) -> URL? {
        return environment.cardPublicKeyBaseURL.appendingPathComponent("hpp/cse/\(token)/json.shtml")
    }
}

private struct PublicKeyResponse: Decodable {
    public let publicKey: String
    
    private enum CodingKeys: CodingKey {
        case publicKey
    }
    
}
