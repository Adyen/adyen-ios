//
// Copyright (c) 2019 Adyen N.V.
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
        
        internal var isEmpty: Bool {
            return [number, securityCode, expiryYear, expiryMonth].allSatisfy { $0 == nil }
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
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    public static func encryptedCard(for card: Card, publicKey: String) throws -> EncryptedCard {
        guard !card.isEmpty else {
            throw CardEncryptor.Error.invalidEncryptionArguments
        }
        let generationDate = Date()
        let number = try card.encryptedNumber(publicKey: publicKey, date: generationDate)
        let expiryYear = try card.encryptedExpiryYear(publicKey: publicKey, date: generationDate)
        let expiryMonth = try card.encryptedExpiryMonth(publicKey: publicKey, date: generationDate)
        let securityCode = try card.encryptedSecurityCode(publicKey: publicKey, date: generationDate)
        
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
    /// - Throws:  `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws:  `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, expiryYear, and holderName, all of them are nil.
    /// - Throws:  `CardEncryptor.Error.unknown` if encryption failed for an unknown reason.
    public static func encryptedToken(for card: Card, holderName: String?, publicKey: String) throws -> String {
        guard let cardToken = try card.encryptedToToken(publicKey: publicKey, holderName: holderName) else {
            // This should never happen,
            // because card.encryptedToToken(publicKey:holderName:) will throw an error if the generated token is some how nil,
            // before reaching here.
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
        session.adyen.dataTask(with: url) { result in
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
    /// and `encryptedCard(for:publicKey:)`.
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
                handleSuccess(for: card, publicKey: key, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
            return
        }
    }
    
    private static func handleSuccess(for card: Card, publicKey: String, completion: @escaping Completion<Result<EncryptedCard, Swift.Error>>) {
        do {
            let encryptedCard = try CardEncryptor.encryptedCard(for: card, publicKey: publicKey)
            completion(.success(encryptedCard))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Encrypts a card.
    /// This methods encapsulates calls to `requestPublicKey(forToken:environment:completion:)`
    /// and `encrypt(_:publicKey:)`.
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
                    completion(.failure(error))
                }
                
            case let .failure(error):
                completion(.failure(error))
            }
            return
        }
    }
    
    // MARK: - Error
    
    /// Describes the error that can occur during card encryption and public key fetching.
    public enum Error: Swift.Error, LocalizedError {
        /// Indicates an unknown error occurred.
        case unknown
        /// Indicates encryption failed  because of invalid card public key or for some other unknown reason.
        case encryptionFailed
        /// Indicates an error when trying to encrypt a card with  card number, securityCode,
        /// expiryMonth, expiryYear, and holderName, all of them are nil.
        case invalidEncryptionArguments
        
        public var errorDescription: String? {
            switch self {
            case .encryptionFailed:
                return "Encryption failed, please check if the public key is a valid one."
            case .invalidEncryptionArguments:
                // swiftlint:disable:next line_length
                return "Trying to encrypt a card with card number, securityCode, expiryMonth, expiryYear, and holderName, all of them are nil"
            case .unknown:
                return "Unknow Error"
            }
        }
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
