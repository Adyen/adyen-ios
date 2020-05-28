//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object that provides helper functions for conding and deconding responses.
/// :nodoc:
public final class Coder {
    
    // MARK: - Decoding
    
    /// :nodoc:
    public static func decode<T: Decodable>(_ data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
    
    /// :nodoc:
    public static func decode<T: Decodable>(_ string: String) throws -> T {
        return try decode(Data(string.utf8))
    }
    
    /// :nodoc:
    public static func decodeBase64<T: Decodable>(_ string: String) throws -> T {
        guard let data = Data(base64Encoded: string) else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Given string is not valid base64.")
            
            throw DecodingError.dataCorrupted(context)
        }
        
        return try decode(data) as T
    }
    
    // MARK: - Encoding
    
    /// :nodoc:
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        return try encoder.encode(value)
    }
    
    /// :nodoc:
    public static func encode<T: Encodable>(_ value: T) throws -> String {
        let data: Data = try encode(value)
        
        guard let string = String(data: data, encoding: .utf8) else {
            fatalError("Failed to convert data to UTF-8 string.")
        }
        
        return string
    }
    
    /// :nodoc:
    public static func encodeBase64<T: Encodable>(_ value: T) throws -> String {
        let encodedValue = try encode(value) as Data
        
        return encodedValue.base64EncodedString()
    }
    
    // MARK: - Private
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return decoder
    }()
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return encoder
    }()
    
}
