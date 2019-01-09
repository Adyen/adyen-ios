//
// Copyright (c) 2019 Adyen B.V.
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
        if #available(iOS 10.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        } else {
            decoder.dateDecodingStrategy = .customISO8601
        }
        
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
        if #available(iOS 10.0, *) {
            encoder.dateEncodingStrategy = .iso8601
        } else {
            encoder.dateEncodingStrategy = .customISO8601
        }
        
        return encoder
    }()
    
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    static let iso8601noFS: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()
}

extension JSONDecoder.DateDecodingStrategy {
    static let customISO8601 = custom { decoder throws -> Date in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601.date(from: string) ?? Formatter.iso8601noFS.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension JSONEncoder.DateEncodingStrategy {
    static let customISO8601 = custom { date, encoder throws in
        var container = encoder.singleValueContainer()
        try container.encode(Formatter.iso8601.string(from: date))
    }
}
