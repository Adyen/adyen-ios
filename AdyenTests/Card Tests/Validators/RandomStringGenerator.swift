//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum RandomStringGenerator {
    static func generateDummyCardPublicKey() -> String {
        return "\(generateRandomNumericString(length: 5))|\(generateRandomAlphaNumericString(length: 512))"
    }
    
    static func generateRandomNumericString(length: Int) -> String {
        let characters: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return generateRandomString(length: length, characters: characters)
    }
    
    static func generateRandomAlphaNumericString(length: Int) -> String {
        let characters: [Character] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return generateRandomString(length: length, characters: characters)
    }
    
    static func generateRandomString(length: Int, characters: [Character]) -> String {
        return String((0..<length).map { _ in characters.randomElement() }.compactMap { $0 })
    }
}
