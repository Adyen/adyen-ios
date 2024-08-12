//
//  File.swift
//
//  Created by Alexander Guretzki on 26/07/2024.
//

import Foundation

extension SDKDump.Element {
    
    func differences(to otherElement: SDKDump.Element) -> [String] {
        var diff = [String]()
        diff += differences(toIsFinal: otherElement.isFinal)
        diff += differences(toIsThrowing: otherElement.isThrowing)
        diff += differences(toHasDiscardableResult: otherElement.hasDiscardableResult)
        diff += differences(toSpiGroupNames: otherElement.spiGroupNames)
        diff += differences(toConformances: otherElement.conformances)

        if let functionDescription = asFunction,
           let otherFunctionDescription = otherElement.asFunction
        {
            diff += functionDescription.differences(toFunction: otherFunctionDescription)
        }
        
        return diff
    }
}

// MARK: Generic comparisons

private extension SDKDump.Element {
    
    func differences(toIsFinal otherIsFinal: Bool) -> [String] {
        guard isFinal != otherIsFinal else { return [] }
            
        if isFinal {
            return ["`final` keyword was added"]
        } else {
            return ["`final` keyword was removed"]
        }
    }
    
    func differences(toIsThrowing otherIsThrowing: Bool) -> [String] {
        guard isThrowing != otherIsThrowing else { return [] }
            
        if isThrowing {
            return ["`throws` keyword was added"]
        } else {
            return ["`throws` keyword was removed"]
        }
    }
    
    func differences(toSpiGroupNames otherSpiGroupNames: [String]?) -> [String] {
        guard spiGroupNames != otherSpiGroupNames else { return [] }
            
        let ownSpiGroupNames = Set(spiGroupNames ?? [])
        let otherSpiGroupNames = Set(otherSpiGroupNames ?? [])
        
        return ownSpiGroupNames.symmetricDifference(otherSpiGroupNames).map {
            if otherSpiGroupNames.contains($0) {
                return "`@_spi(\($0))` was added"
            } else {
                return "`@_spi(\($0))` was removed"
            }
        }
    }
    
    func differences(toConformances otherConformances: [Conformance]?) -> [String] {
        guard conformances != otherConformances else { return [] }
            
        let ownConformances = Set(conformances ?? [])
        let otherConformances = Set(otherConformances ?? [])
        
        return ownConformances.symmetricDifference(otherConformances).map {
            if otherConformances.contains($0) {
                return "`\($0.printedName)` conformance was added"
            } else {
                return "`\($0.printedName)` conformance was removed"
            }
        }
    }
    
    func differences(toAccessors otherAccessors: [SDKDump.Element]?) -> [String] {
        guard accessors != otherAccessors else { return [] }
            
        let ownAccessors = Set(accessors?.map(\.printedName) ?? [])
        let otherAccessors = Set(otherAccessors?.map(\.printedName) ?? [])
        
        return ownAccessors.symmetricDifference(otherAccessors).map {
            if otherAccessors.contains($0) {
                return "`\($0)` accessor was added"
            } else {
                return "`\($0)` accessor was removed"
            }
        }
    }
    
    func differences(toHasDiscardableResult otherHasDiscardableResult: Bool) -> [String] {
        guard hasDiscardableResult != otherHasDiscardableResult else { return [] }
            
        if hasDiscardableResult {
            return ["`@discardableResult` keyword was added"]
        } else {
            return ["`@discardableResult` keyword was removed"]
        }
    }
}
