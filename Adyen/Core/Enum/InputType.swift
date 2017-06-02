//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Defines types of payment details.
public enum InputType: String {
    
    /// Text input type.
    case text
    
    /// Boolean input type.
    case boolean
    
    /// Input type should be selected from the given list.
    case select
    
    /// IBAN input type.
    case iban
    
    /// CVC input type.
    case cvc
    
    /// Card token input type.
    case cardToken
    
    /// Apple Pay token input type.
    case applePayToken
}
