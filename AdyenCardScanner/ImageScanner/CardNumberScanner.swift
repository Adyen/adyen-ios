//
//  CardNumberScanner.swift
//  AdyenCardScanner
//
//  Created by Mohamed Eldoheiri on 16/11/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal protocol TextScanner {
    func scan(text: String) throws -> [CardElement]
}

internal enum CardElement {
    case pan(String)
}

internal struct CardNumberScanner: TextScanner {
    
    internal enum Error: Swift.Error {
        case invalidNumericNumber
        case invalidPAN
    }
    
    internal func scan(text: String) throws -> [CardElement] {
        let sanitizedString = NumericFormatter().sanitizedValue(for: text)
        guard sanitizedString.count >= CardNumberValidator.Constants.minPanLength else { throw Error.invalidPAN }
        var result = [CardElement]()
        for start in (0...sanitizedString.count - CardNumberValidator.Constants.minPanLength) {
            for end in (start...sanitizedString.count) {
                let startIndex = sanitizedString.index(sanitizedString.startIndex, offsetBy: start)
                let endIndex = sanitizedString.index(sanitizedString.startIndex, offsetBy: end)
                guard let element = try? validate(text: String(sanitizedString[startIndex..<endIndex])) else { continue }
                result.append(element)
            }
        }
        return result
    }
    
    private func validate(text: String) throws -> CardElement {
        let cardNumberValidator = CardNumberValidator(isLuhnCheckEnabled: true, isEnteredBrandSupported: true)
        let numericValidator = NumericStringValidator(minimumLength: CardNumberValidator.Constants.minPanLength,
                                                      maximumLength: CardNumberValidator.Constants.maxPanLength)
        guard numericValidator.isValid(text) else {
            throw Error.invalidNumericNumber
        }
        guard cardNumberValidator.isValid(text) else {
            throw Error.invalidPAN
        }
        let cardTypes: [CardType] = [.masterCard, .visa, .americanExpress, .bcmc, .maestro, .maestroUK, .elo, .jcb]
        guard cardTypes.adyen.type(forCardNumber: text) != nil else { throw Error.invalidPAN }
        return .pan(text)
    }
}
