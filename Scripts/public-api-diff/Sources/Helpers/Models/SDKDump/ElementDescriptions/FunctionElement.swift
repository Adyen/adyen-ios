//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump.Element {
    
    public var asFunction: SDKDump.FunctionElement? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct FunctionElement: CustomStringConvertible {
        
        public var declaration: String? { underlyingElement.declKind == .func ? "func" : nil }
        
        public var name: String { extractName() }
        
        public var arguments: [Argument] { extractArguments() }
        
        public var returnType: String? { extractReturnType() }
        
        public var description: String { compileDescription() }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .func || underlyingElement.declKind == .constructor || underlyingElement.declKind == .subscriptDeclaration else {
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
        let ownership: String?
        let defaultArgument: String?
        
        public var description: String {
            let nameAndType = [
                "\(name):",
                ownership, type
            ].compactMap { $0 }.joined(separator: " ")
            
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
        
        let verboseFunctionName = [
            name,
            underlyingElement.genericSig,
            "(\(argumentList))"
        ].compactMap { $0 }.joined()
        
        let components: [String?] = [
            underlyingElement.isMutating ? "mutating" : nil,
            declaration,
            verboseFunctionName,
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
        // TODO: Add support for: class func, rethrows, async
        // See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Enumerations-with-Indirection
        
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
                    type: Constants.unknownType,
                    ownership: nil,
                    defaultArgument: nil
                )
            }
            
            let type = parameterTypes[index]
            return .init(
                name: component,
                type: type.verboseName,
                ownership: type.paramValueOwnership?.lowercased(),
                defaultArgument: type.hasDefaultArg ? Constants.defaultArg : nil
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
