//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct Change: Equatable {
    enum ChangeType: Equatable {
        case addition(description: String)
        case removal(description: String)
        
        var icon: String {
            switch self {
            case .addition: "❇️ "
            case .removal: "😶‍🌫️"
            }
        }
    }
    
    var changeType: ChangeType
    var parentName: String
}

extension Change.ChangeType {

    var isAddition: Bool {
        switch self {
        case .addition:
            return true
        case .removal:
            return false
        }
    }

    var isRemoval: Bool {
        switch self {
        case .addition:
            return false
        case .removal:
            return true
        }
    }
}

extension [String: [Change]] {
    
    var totalChangeCount: Int {
        var totalChangeCount = 0
        keys.forEach { targetName in
            totalChangeCount += self[targetName]?.count ?? 0
        }
        return totalChangeCount
    }
}
