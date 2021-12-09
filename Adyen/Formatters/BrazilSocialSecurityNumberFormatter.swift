//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Formats a string based on Brazil's social security numbers (CPF and CNPJ) formatting rules.
/// CPF is an 11 digit number and formatted like `123.123.123-12` and
/// CNPJ is a 14 digit number and formatted like `12.123.123/1234-12`
public final class BrazilSocialSecurityNumberFormatter: NumericFormatter {
    
    private enum Constants {
        static let maxDigits = 11
    }
    
    override public func formattedValue(for value: String) -> String {
        let sanitizedNumber = sanitizedValue(for: value)
        let grouping = formatGrouping(for: sanitizedNumber.count)
        let specialCharactersToAdd = specialCharacters(for: sanitizedNumber.count)
        let formattedNumberComponents = sanitizedNumber.adyen.components(withLengths: grouping)
        
        // add one element from each array, then move to next elements
        // "12" + "." + "456" + "-" etc
        let merged = formattedNumberComponents.enumerated().map { index, element -> String in
            if index == formattedNumberComponents.count - 1 {
                return element
            }
            if index < specialCharactersToAdd.count {
                return element + specialCharactersToAdd[index]
            }
            return element
        }
        
        return merged.joined()
    }
    
    private func formatGrouping(for length: Int) -> [Int] {
        switch length {
        case ...Constants.maxDigits:
            return [3, 3, 3, 2]
        default:
            return [2, 3, 3, 4, 2]
        }
    }
    
    private func specialCharacters(for length: Int) -> [String] {
        switch length {
        case ...Constants.maxDigits:
            return [".", ".", "-"]
        default:
            return [".", ".", "/", "-"]
        }
    }
}
