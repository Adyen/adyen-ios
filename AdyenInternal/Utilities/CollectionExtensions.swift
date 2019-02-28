//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Collection {
    /// Groups the collection by a key retrieved for each element.
    ///
    /// - Parameter closure: A closure that returns a grouping key for each element in the collection.
    /// - Returns: A collection grouped by the keys retrieved for each element.g
    func grouped<G: Hashable>(by closure: (Element) -> G?) -> [[Element]] {
        var groups = [[Element]]()
        
        for element in self {
            let key = closure(element)
            var active = Int()
            var isNewGroup = true
            var array = [Element]()
            
            if key != nil {
                for (index, group) in groups.enumerated() {
                    let firstKey = closure(group[0])
                    if firstKey == key {
                        array = group
                        active = index
                        isNewGroup = false
                        break
                    }
                }
            }
            
            array.append(element)
            
            if isNewGroup {
                groups.append(array)
            } else {
                groups.remove(at: active)
                groups.insert(array, at: active)
            }
        }
        
        return groups
    }
    
}
