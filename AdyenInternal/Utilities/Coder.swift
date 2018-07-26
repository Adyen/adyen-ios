//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public final class Coder {
    public static func decode<T: Decodable>(_ data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
    
    public static func decode<T: Decodable>(_ string: String) throws -> T {
        return try decode(Data(string.utf8))
    }
    
    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return decoder
    }()
    
    public static func encode<T: Encodable>(_ value: T) throws -> Data {
        return try encoder.encode(value)
    }
    
    public static func encode<T: Encodable>(_ value: T) throws -> String {
        let data: Data = try encode(value)
        
        guard let string = String(data: data, encoding: .utf8) else {
            fatalError("Failed to convert data to UTF-8 string.")
        }
        
        return string
    }
    
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        return encoder
    }()
    
}
