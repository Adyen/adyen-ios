//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 01/08/2024.
//

import Foundation

extension SDKDump.Element {
    
    public var asFunction: SDKDump.FunctionElement? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct FunctionElement: CustomStringConvertible {
        
        public var declaration: String { "func" }
        
        public var name: String { extractName() }
        
        public var arguments: [Argument] { extractArguments() }
        
        public var returnType: String? { extractReturnType() }
        
        public var description: String { compileDescription() }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .func || underlyingElement.declKind == .constructor else {
                return nil
            }
            
            self.underlyingElement = underlyingElement
        }
    }
}

// MARK: Argument

extension SDKDump.FunctionElement {
    
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
}

// MARK: - Privates

private extension SDKDump.FunctionElement {
    
    func compileDescription() -> String {
        guard let returnType else { return underlyingElement.printedName }
        
        let argumentList = arguments
            .map(\.description)
            .joined(separator: ", ")
        
        let components: [String?] = [
            "\(declaration)",
            "\(name)(\(argumentList))",
            underlyingElement.isThrowing ? "throws" : nil,
            "->",
            returnType
        ]
        
        return components
            .compactMap { $0 }
            .joined(separator: " ")
    }
    
    func extractName() -> String {
        underlyingElement.printedName.components(separatedBy: "(").first ?? ""
    }
    
    func extractArguments() -> [Argument] {
        
        let parameterNames = Self.parameterNames(
            from: underlyingElement.printedName,
            functionName: name
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
    
    func extractReturnType() -> String? {
        guard let returnType = underlyingElement.children.first?.printedName else { return nil }
        return returnType == "()" ? "Swift.Void" : returnType
    }
    
    /// Extracts the parameter names from the `printedName`
    static func parameterNames(from printedName: String, functionName: String) -> [String] {
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
                return "`\($0)` was added"
            } else {
                return "`\($0)` was removed"
            }
        }
    }
}
