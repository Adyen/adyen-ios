//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol RandomStringGenerating {
    
    func generateRandomString() -> String
}

struct RandomStringGenerator: RandomStringGenerating {
    
    func generateRandomString() -> String {
        UUID().uuidString
    }
}
