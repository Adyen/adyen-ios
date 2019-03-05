//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
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
    
    /// Encrypts Card information with AES-CBC using generated AES256 session key and IV (12)
    /// Encrypts the session key with RSA using public key (using Keychain)
    ///
    /// - Parameters:
    ///   - card: Card containing data to be encrypted.
    ///   - publicKey: Public key in Hex with format "Exponent|Modulus".
    ///   - generationDate: card object generation date.
    /// - Returns: Object with individually encrypted fields.
    public static func encryptedCard(for card: Card, publicKey: String, generationDate: Date) -> EncryptedCard {
        let number = card.encryptedNumber(publicKey: publicKey, date: generationDate)
        let expiryYear = card.encryptedExpiryYear(publicKey: publicKey, date: generationDate)
        let expiryMonth = card.encryptedExpiryMoth(publicKey: publicKey, date: generationDate)
        let securityCode = card.encryptedSecurityCode(publicKey: publicKey, date: generationDate)
        
        return EncryptedCard(number: number, securityCode: securityCode, expiryMonth: expiryMonth, expiryYear: expiryYear)
    }
    
    /// Encrypts Card information with AES-CBC using generated AES256 session key and IV (12)
    /// Encrypts the session key with RSA using public key (using Keychain)
    ///
    /// - Parameters:
    ///   - card: Card containing data to be encrypted.
    ///   - holderName: Card holder name if any provided.
    ///   - publicKey: Public key in Hex with format "Exponent|Modulus".
    ///   - generationDate: card object generation date.
    /// - Returns: String with encrypted token or throws in case of error.
    public static func encryptedToken(for card: Card, holderName: String?, publicKey: String, generationDate: Date) throws -> String {
        guard let cardToken = card.encryptedToToken(publicKey: publicKey, holderName: holderName, date: generationDate) else {
            throw Error.unknown
        }
        
        return cardToken
    }
    
    /// Fetches the Public encryption key from Adyen backend.
    ///
    /// - Parameters:
    ///   - token: your token.
    ///   - environment: environment for public key fetch.
    ///   - completion: closure for handling fetched key or failure.
    public static func requestPublicKey(forToken token: String, environment: Environment, completion: @escaping Completion<Result<String>>) {
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
    
    /// Encrypts Card information after requesting public key from token.
    /// This methods encapsulates calls to `requestPublicKey(forToken token: environment: completion:)` and `encryptedCard(for card: publicKey: generationDate:)`
    ///
    /// - Parameters:
    ///   - card: Card containing data to be encrypted.
    ///   - publicKeyToken: your token.
    ///   - generationDate: card object generation date.
    ///   - environment: environment for public key fetch.
    ///   - completion: closure for handling encrypted card or failure.
    public static func encryptedCard(for card: Card, publicKeyToken: String, generationDate: Date, environment: Environment, completion: @escaping Completion<Result<EncryptedCard>>) {
        requestPublicKey(forToken: publicKeyToken, environment: environment) { result in
            switch result {
            case let .success(key):
                let encryptedCard = CardEncryptor.encryptedCard(for: card, publicKey: key, generationDate: generationDate)
                completion(.success(encryptedCard))
                
            case let .failure(error):
                completion(.failure(error))
            }
            return
        }
    }
    
    /// Encrypts Card information after requesting public key from token.
    /// This methods encapsulates calls to `requestPublicKey(forToken token: environment: completion:)` and `encrypt(_ card: publicKey: generationDate:)`
    ///
    /// - Parameters:
    ///   - card: Card containing data to be encrypted.
    ///   - holderName: Card holder name if any provided.
    ///   - publicKeyToken: your token.
    ///   - generationDate: card object generation date.
    ///   - environment: environment for public key fetch.
    ///   - completion: closure for handling encrypted card token or failure.
    public static func encryptedToken(for card: Card, holderName: String?, publicKeyToken: String, generationDate: Date, environment: Environment, completion: @escaping Completion<Result<String>>) {
        requestPublicKey(forToken: publicKeyToken, environment: environment) { result in
            switch result {
            case let .success(key):
                do {
                    let encryptedCardToken = try CardEncryptor.encryptedToken(for: card, holderName: holderName, publicKey: key, generationDate: generationDate)
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
    
    private static func publicKeyFetchUrl(forToken token: String, environment: Environment) -> URL? {
        let string = "https://\(environment.rawValue).adyen.com/hpp/cse/\(token)/json.shtml"
        
        guard let url = URL(string: string) else {
            assertionFailure("Failed to construct public key URL.")
            return nil
        }
        
        return url
    }
}

public extension CardEncryptor {
    /// Enum specifying the environments for which a public key can be retrieved.
    enum Environment: String, Decodable {
        /// Indicates a live environment.
        case live
        
        /// Indicates a test environment.
        case test
        
    }
}

private struct PublicKeyResponse: Decodable {
    public let publicKey: String
    
    private enum CodingKeys: CodingKey {
        case publicKey
    }
    
}
