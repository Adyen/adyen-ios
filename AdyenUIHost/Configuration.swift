//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// Fill in your app identifier and secret key here.
struct Configuration {
    static let appSecretKey = ""
    
    static var isFilledIn: Bool {
        guard appSecretKey.characters.isEmpty == false else {
            return false
        }
        
        return true
    }
}
