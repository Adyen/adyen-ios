//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum RandomStringGenerator {
    static func generateDummyCardPublicKey() -> String {
        "\(generateRandomHexadecimalString(length: 5))|\(generateRandomHexadecimalString(length: 512))"
    }
    
    static func generateRandomNumericString(length: Int) -> String {
        let characters: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return generateRandomString(length: length, characters: characters)
    }
    
    static func generateRandomHexadecimalString(length: Int) -> String {
        let characters: [Character] = ["A", "B", "C", "D", "E", "F", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return generateRandomString(length: length, characters: characters)
    }
    
    static func generateRandomString(length: Int, characters: [Character]) -> String {
        String((0..<length).map { _ in characters.randomElement() }.compactMap { $0 })
    }
}
