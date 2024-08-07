//
//  File.swift
//
//  Created by Alexander Guretzki on 26/07/2024.
//

import Foundation

extension SDKDump.Element {
    
    func difference(to otherElement: SDKDump.Element) -> [String] {
        var diff = [String]()
        diff += difference(toIsFinal: otherElement.isFinal)
        diff += difference(toIsThrowing: otherElement.isThrowing)
        diff += difference(toSpiGroupNames: otherElement.spiGroupNames)
        diff += difference(toConformances: otherElement.conformances)

        if let functionDescription = SDKDump.FunctionDescription(underlyingElement: self), 
            let otherFunctionDescription = SDKDump.FunctionDescription(underlyingElement: otherElement)
        {
            diff += functionDescription.difference(toFunction: otherFunctionDescription)
        }
        
        return diff
    }
    
    func difference(toIsFinal otherIsFinal: Bool) -> [String] {
        guard isFinal != otherIsFinal else { return [] }
            
        if isFinal {
            return ["`final` keyword was added"]
        } else {
            return ["`final` keyword was removed"]
        }
    }
    
    func difference(toIsThrowing otherIsThrowing: Bool) -> [String] {
        guard isThrowing != otherIsThrowing else { return [] }
            
        if isThrowing {
            return ["`throws` keyword was added"]
        } else {
            return ["`throws` keyword was removed"]
        }
    }
    
    func difference(toSpiGroupNames otherSpiGroupNames: [String]?) -> [String] {
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
    
    func difference(toConformances otherConformances: [Conformance]?) -> [String] {
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
}

extension SDKDump.FunctionDescription {
    
    func difference(toFunction otherFunction: SDKDump.FunctionDescription) -> [String] {
        let ownArguments = arguments
        let otherArguments = otherFunction.arguments
        
        guard ownArguments != otherArguments else { return [] }
        
        let ownArgumentNames = Set(arguments.map(\.description))
        let otherArgumentNames = Set(otherArguments.map(\.description))
        
        // TODO: Figure out more in depth if the order, type and/or default arg changed
        
        return ownArgumentNames.symmetricDifference(otherArgumentNames).map {
            if otherArgumentNames.contains($0) {
                return "`\($0)` was added"
            } else {
                return "`\($0)` was removed"
            }
        }
    }
}
