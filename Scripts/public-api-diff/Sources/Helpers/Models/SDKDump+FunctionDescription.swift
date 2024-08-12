//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 01/08/2024.
//

import Foundation

extension SDKDump.Element {
    
    var functionDescription: SDKDump.FunctionDescription? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct FunctionDescription: CustomStringConvertible {
        
        public struct Argument: Equatable, CustomStringConvertible {
            let name: String
            let type: String
            let defaultArgument: String?
            
            public var description: String {
                let nameAndType = "\(name): \(type)"
                if let defaultArgument {
                    return "\(nameAndType) = \(defaultArgument)"
                }
                return nameAndType
            }
        }
        
        public var functionName: String {
            underlyingElement.printedName.components(separatedBy: "(").first ?? ""
        }
        
        public var arguments: [Argument] {
 
            let parameterNames = Self.parameterNames(
                from: underlyingElement.printedName,
                functionName: functionName
            )
            
            let parameterTypes = Self.parameterTypes(
                for: underlyingElement
            )
            
            return parameterNames.enumerated().map { index, component in
                
                guard index < parameterTypes.count else {
                    return .init(
                        name: component,
                        type: "UNKNOWN_TYPE",
                        defaultArgument: nil
                    )
                }
                
                let type = parameterTypes[index]
                return .init(
                    name: component,
                    type: type.verboseName,
                    defaultArgument: type.hasDefaultArg ? "$DEFAULT_ARG" : nil
                )
            }
        }
        
        public var returnType: String? {
            guard let returnType = underlyingElement.children.first?.printedName else { return nil }
            return returnType == "()" ? "Swift.Void" : returnType
        }
        
        public var description: String {
            guard let returnType else { return underlyingElement.printedName }
            
            let argumentList = arguments
                .map(\.description)
                .joined(separator: ", ")
            
            let components: [String?] = [
                "\(functionName)(\(argumentList))",
                underlyingElement.isThrowing ? "throws" : nil,
                "->",
                returnType
            ]
            
            return components
                .compactMap { $0 }
                .joined(separator: " ")
        }
        
        private let underlyingElement: SDKDump.Element
        
        init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .func || underlyingElement.declKind == .constructor else {
                return nil
            }
            
            self.underlyingElement = underlyingElement
        }
    }
}

// MARK: - Arguments

extension SDKDump.FunctionDescription {
    
    /// Extracts the parameter names from the `printedName`
    private static func parameterNames(from printedName: String, functionName: String) -> [String] {
        var sanitizedArguments = printedName
        sanitizedArguments.removeFirst(functionName.count)
        sanitizedArguments.removeFirst() // `(`
        if sanitizedArguments.hasSuffix(":)") {
            sanitizedArguments.removeLast(2) // `:)`
        } else {
            sanitizedArguments.removeLast() // `)`
        }
        
        if sanitizedArguments.isEmpty { return [] }
        
        return sanitizedArguments.components(separatedBy: ":")
    }
    
    /// Extracts the parameter types from the underlying element
    private static func parameterTypes(for underlyingElement: SDKDump.Element) -> [SDKDump.Element] {
        Array(underlyingElement.children.suffix(from: 1)) // First element is the return type
    }
}

// MARK: - Differences

extension SDKDump.FunctionDescription {
    
    func differences(toFunction otherFunction: Self) -> [String] {
        let ownArguments = arguments
        let otherArguments = otherFunction.arguments
        
        guard ownArguments != otherArguments else { return [] }
        
        // TODO: Indicate more in depth if the order, type and/or default arg changed
        
        let ownArgumentNames = Set(arguments.map(\.description))
        let otherArgumentNames = Set(otherArguments.map(\.description))
        
        return ownArgumentNames.symmetricDifference(otherArgumentNames).map {
            if otherArgumentNames.contains($0) {
                return "`\($0)` was added"
            } else {
                return "`\($0)` was removed"
            }
        }
    }
}
