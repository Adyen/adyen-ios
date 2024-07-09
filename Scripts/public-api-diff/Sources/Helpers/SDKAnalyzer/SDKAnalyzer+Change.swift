//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKAnalyzer {
    
    struct Change: Equatable {
        enum ChangeType: Equatable {
            case addition
            case removal
            
            var icon: String {
                switch self {
                case .addition: "❇️ "
                case .removal: "😶‍🌫️"
                }
            }
        }
        
        var changeType: ChangeType
        var parentName: String
        var changeDescription: String
    }
}

extension [String: [SDKAnalyzer.Change]] {
    
    var totalChangeCount: Int {
        var totalChangeCount = 0
        keys.forEach { targetName in
            totalChangeCount += self[targetName]?.count ?? 0
        }
        return totalChangeCount
    }
}
