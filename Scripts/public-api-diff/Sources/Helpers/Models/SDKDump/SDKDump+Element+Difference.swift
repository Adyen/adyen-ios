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
        diff += differences(toGenericSig: otherElement.genericSig)
        diff += differences(toIsObjcAccessible: otherElement.isObjcAccessible)
        diff += differences(toIsOverride: otherElement.isOverride)
        diff += differences(toIsDynamic: otherElement.isDynamic)
        diff += differences(toIsMutating: otherElement.isMutating)
        diff += differences(toIsRequired: otherElement.isRequired)

        if let functionDescription = asFunction, let otherFunctionDescription = otherElement.asFunction {
            diff += functionDescription.differences(toFunction: otherFunctionDescription)
        }
        
        return diff.sorted()
    }
}

private extension SDKDump.Element {
    
    func differences(toIsFinal otherIsFinal: Bool) -> [String] {
        guard isFinal != otherIsFinal else { return [] }
            
        if otherIsFinal {
            return ["Added `final` keyword"]
        } else {
            return ["Removed `final` keyword"]
        }
    }
    
    func differences(toIsThrowing otherIsThrowing: Bool) -> [String] {
        guard isThrowing != otherIsThrowing else { return [] }
            
        if otherIsThrowing {
            return ["Added `throws` keyword"]
        } else {
            return ["Removed `throws` keyword"]
        }
    }
    
    func differences(toSpiGroupNames otherSpiGroupNames: [String]?) -> [String] {
        guard spiGroupNames != otherSpiGroupNames else { return [] }
            
        let ownSpiGroupNames = Set(spiGroupNames ?? [])
        let otherSpiGroupNames = Set(otherSpiGroupNames ?? [])
        
        return ownSpiGroupNames.symmetricDifference(otherSpiGroupNames).map {
            if otherSpiGroupNames.contains($0) {
                return "Added `@_spi(\($0))`"
            } else {
                return "Removed `@_spi(\($0))`"
            }
        }
    }
    
    func differences(toConformances otherConformances: [Conformance]?) -> [String] {
        guard conformances != otherConformances else { return [] }
            
        let ownConformances = Set(conformances ?? [])
        let otherConformances = Set(otherConformances ?? [])
        
        return ownConformances.symmetricDifference(otherConformances).map {
            if otherConformances.contains($0) {
                return "Added `\($0.printedName)` conformance"
            } else {
                return "Removed `\($0.printedName)` conformance"
            }
        }
    }
    
    func differences(toAccessors otherAccessors: [SDKDump.Element]?) -> [String] {
        guard accessors != otherAccessors else { return [] }
            
        let ownAccessors = Set(accessors?.map(\.printedName) ?? [])
        let otherAccessors = Set(otherAccessors?.map(\.printedName) ?? [])
        
        return ownAccessors.symmetricDifference(otherAccessors).map {
            if otherAccessors.contains($0) {
                return "Added `\($0)` accessor"
            } else {
                return "Removed `\($0)` accessor"
            }
        }
    }
    
    func differences(toHasDiscardableResult otherHasDiscardableResult: Bool) -> [String] {
        guard hasDiscardableResult != otherHasDiscardableResult else { return [] }
            
        if otherHasDiscardableResult {
            return ["Added `@discardableResult` keyword"]
        } else {
            return ["Removed `@discardableResult` keyword"]
        }
    }
    
    func differences(toInitKind otherInitKind: String?) -> [String] {
        guard let initKind, let otherInitKind, initKind != otherInitKind else { return [] }
        
        return ["Changed from `\(otherInitKind.lowercased())` to `\(initKind.lowercased()) init"]
    }
    
    func differences(toGenericSig otherGenericSig: String?) -> [String] {
        guard genericSig != otherGenericSig else { return [] }
        
        if let genericSig, let otherGenericSig {
            return ["Changed generic signature from `\(genericSig)` to `\(otherGenericSig)"]
        }
        
        if let otherGenericSig {
            return ["Added generic signature `\(otherGenericSig)`"]
        }
        
        if let genericSig {
            return ["Removed generic signature `\(genericSig)`"]
        }
        
        return []
    }
    
    func differences(toIsObjcAccessible otherIsObjcAccessible: Bool) -> [String] {
        guard isObjcAccessible != otherIsObjcAccessible else { return [] }
        
        if otherIsObjcAccessible {
            return ["Added `@objc` keyword"]
        } else {
            return ["Removed `@objc` keyword"]
        }
    }
    
    func differences(toIsOverride otherIsOverride: Bool) -> [String] {
        guard isOverride != otherIsOverride else { return [] }
        
        if otherIsOverride {
            return ["Added `override` keyword"]
        } else {
            return ["Removed `override` keyword"]
        }
    }
    
    func differences(toIsDynamic otherIsDynamic: Bool) -> [String] {
        guard isDynamic != otherIsDynamic else { return [] }
        
        if otherIsDynamic {
            return ["Added `dynamic` keyword"]
        } else {
            return ["Removed `dynamic` keyword"]
        }
    }
    
    func differences(toIsMutating otherIsMutating: Bool) -> [String] {
        guard isMutating != otherIsMutating else { return [] }
        
        if otherIsMutating {
            return ["Added `mutating` keyword"]
        } else {
            return ["Removed `mutating` keyword"]
        }
    }
    
    func differences(toIsRequired otherIsRequired: Bool) -> [String] {
        guard isRequired != otherIsRequired else { return [] }
        
        if otherIsRequired {
            return ["Added `required` keyword"]
        } else {
            return ["Removed `required` keyword"]
        }
    }
}

extension SDKDump.FunctionElement {
    
    func differences(toFunction otherFunction: Self) -> [String] {
        let ownArguments = arguments
        let otherArguments = otherFunction.arguments
        
        guard ownArguments != otherArguments else { return [] }
        
        // TODO: Indicate more in depth if the order, type and/or default arg changed
        
        let ownArgumentNames = Set(arguments.map(\.description))
        let otherArgumentNames = Set(otherArguments.map(\.description))
        
        return ownArgumentNames.symmetricDifference(otherArgumentNames).map {
            if otherArgumentNames.contains($0) {
                return "Added `\($0)`"
            } else {
                return "Removed `\($0)`"
            }
        }
    }
}
