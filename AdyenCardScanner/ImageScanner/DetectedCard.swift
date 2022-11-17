//
//  DetectedCard.swift
//  AdyenCardScanner
//
//  Created by Mohamed Eldoheiri on 16/11/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation

/// Contains the information of a card that is yet to be encrypted.
public final class DetectedCard {

    /// The card number.
    public var numberCandidates: [String]

    /// The card's security code.
    public var securityCodeCandidates: [String]

    /// The month the card expires.
    public var expiryMonthCandidates: [String]

    /// The year the card expires.
    public var expiryYearCandidates: [String]

    /// The name of the card holder.
    public var holderCandidates: [String]

    
    public init(numberCandidates: [String] = [],
                securityCodeCandidates: [String] = [],
                expiryMonthCandidates: [String] = [],
                expiryYearCandidates: [String] = [],
                holderCandidates: [String] = []) {
        self.numberCandidates = numberCandidates
        self.securityCodeCandidates = securityCodeCandidates
        self.expiryMonthCandidates = expiryMonthCandidates
        self.expiryYearCandidates = expiryYearCandidates
        self.holderCandidates = holderCandidates
    }

    public var isEmpty: Bool {
        [numberCandidates, securityCodeCandidates, expiryYearCandidates, expiryMonthCandidates].allSatisfy({ $0.isEmpty }) 
    }

}
