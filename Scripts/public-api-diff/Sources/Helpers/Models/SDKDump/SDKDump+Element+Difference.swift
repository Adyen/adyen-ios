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
        diff += differences(toIsOpen: otherElement.isOpen)
        diff += differences(toIsInternal: otherElement.isInternal)
        diff += differences(toIsPrefix: otherElement.isPrefix)
        diff += differences(toIsInfix: otherElement.isInfix)
        diff += differences(toIsPostfix: otherElement.isPostfix)
        diff += differences(toIsInlinable: otherElement.isInlinable)
        diff += differences(toIsIndirect: otherElement.isIndirect)

        if let functionDescription = asFunction, let otherFunctionDescription = otherElement.asFunction {
            diff += functionDescription.differences(toFunction: otherFunctionDescription)
        }
        
        return diff.sorted()
    }
}

private extension SDKDump.Element {
    
    func differences(toIsFinal otherIsFinal: Bool) -> [String] {
        guard isFinal != otherIsFinal else { return [] }
        return ["\(otherIsFinal ? "Added" : "Removed") `final` keyword"]
    }
    
    func differences(toIsThrowing otherIsThrowing: Bool) -> [String] {
        guard isThrowing != otherIsThrowing else { return [] }
        return ["\(otherIsThrowing ? "Added" : "Removed") `throws` keyword"]
    }
    
    func differences(toSpiGroupNames otherSpiGroupNames: [String]?) -> [String] {
        guard spiGroupNames != otherSpiGroupNames else { return [] }
            
        let ownSpiGroupNames = Set(spiGroupNames ?? [])
        let otherSpiGroupNames = Set(otherSpiGroupNames ?? [])
        
        return ownSpiGroupNames.symmetricDifference(otherSpiGroupNames).map {
            "\(otherSpiGroupNames.contains($0) ? "Added" : "Removed") `@_spi(\($0))`"
        }
    }
    
    func differences(toConformances otherConformances: [Conformance]?) -> [String] {
        guard conformances != otherConformances else { return [] }
            
        let ownConformances = Set(conformances ?? [])
        let otherConformances = Set(otherConformances ?? [])
        
        return ownConformances.symmetricDifference(otherConformances).map {
            "\(otherConformances.contains($0) ? "Added" : "Removed") `\($0.printedName)` conformance"
        }
    }
    
    func differences(toAccessors otherAccessors: [SDKDump.Element]?) -> [String] {
        guard accessors != otherAccessors else { return [] }
            
        let ownAccessors = Set(accessors?.map(\.printedName) ?? [])
        let otherAccessors = Set(otherAccessors?.map(\.printedName) ?? [])
        
        return ownAccessors.symmetricDifference(otherAccessors).map {
            "\(otherAccessors.contains($0) ? "Added" : "Removed") `\($0)` accessor"
        }
    }
    
    func differences(toHasDiscardableResult otherHasDiscardableResult: Bool) -> [String] {
        guard hasDiscardableResult != otherHasDiscardableResult else { return [] }
        return ["\(otherHasDiscardableResult ? "Added" : "Removed") `@discardableResult` keyword"]
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
        return ["\(otherIsObjcAccessible ? "Added" : "Removed") `@objc` keyword"]
    }
    
    func differences(toIsOverride otherIsOverride: Bool) -> [String] {
        guard isOverride != otherIsOverride else { return [] }
        return ["\(otherIsOverride ? "Added" : "Removed") `override` keyword"]
    }
    
    func differences(toIsDynamic otherIsDynamic: Bool) -> [String] {
        guard isDynamic != otherIsDynamic else { return [] }
        return ["\(otherIsDynamic ? "Added" : "Removed") `dynamic` keyword"]
    }
    
    func differences(toIsMutating otherIsMutating: Bool) -> [String] {
        guard isMutating != otherIsMutating else { return [] }
        return ["\(otherIsMutating ? "Added" : "Removed") `mutating` keyword"]
    }
    
    func differences(toIsRequired otherIsRequired: Bool) -> [String] {
        guard isRequired != otherIsRequired else { return [] }
        return ["\(otherIsRequired ? "Added" : "Removed") `required` keyword"]
    }
    
    func differences(toIsOpen otherIsOpen: Bool) -> [String] {
        guard isOpen != otherIsOpen else { return [] }
        return ["\(otherIsOpen ? "Added" : "Removed") `open` keyword"]
    }
    
    func differences(toIsInternal otherIsInternal: Bool) -> [String] {
        guard isInternal != otherIsInternal else { return [] }
        return ["\(otherIsInternal ? "Added" : "Removed") `internal` keyword"]
    }
    
    func differences(toIsPrefix otherIsPrefix: Bool) -> [String] {
        guard isPrefix != otherIsPrefix else { return [] }
        return ["\(otherIsPrefix ? "Added" : "Removed") `prefix` keyword"]
    }
    
    func differences(toIsPostfix otherIsPostfix: Bool) -> [String] {
        guard isPostfix != otherIsPostfix else { return [] }
        return ["\(otherIsPostfix ? "Added" : "Removed") `postfix` keyword"]
    }
    
    func differences(toIsInfix otherIsInfix: Bool) -> [String] {
        guard isInfix != otherIsInfix else { return [] }
        return ["\(otherIsInfix ? "Added" : "Removed") `infix` keyword"]
    }
    
    func differences(toIsInlinable otherIsInlinable: Bool) -> [String] {
        guard isInlinable != otherIsInlinable else { return [] }
        return ["\(otherIsInlinable ? "Added" : "Removed") `@inlinable` keyword"]
    }
    
    func differences(toIsIndirect otherIsIndirect: Bool) -> [String] {
        guard isIndirect != otherIsIndirect else { return [] }
        return ["\(otherIsIndirect ? "Added" : "Removed") `indirect` keyword"]
    }
}

extension SDKDump.FunctionElement {
    
    func differences(toFunction otherFunction: Self) -> [String] {
        let ownArguments = arguments
        let otherArguments = otherFunction.arguments
        
        guard ownArguments != otherArguments else { return [] }
        
        let ownArgumentNames = Set(arguments.map(\.description))
        let otherArgumentNames = Set(otherArguments.map(\.description))
        
        return ownArgumentNames.symmetricDifference(otherArgumentNames).map {
            "\(otherArgumentNames.contains($0) ? "Added" : "Removed") `\($0)`"
        }
    }
}
