//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 01/08/2024.
//

import Foundation

extension SDKDump {
    
    struct FunctionDescription {
        
        struct Argument: Equatable {
            let name: String
            let type: String
            let defaultArgument: String?
            
            var description: String {
                let nameAndType = "\(name): \(type)"
                if let defaultArgument {
                    return "\(nameAndType) = \(defaultArgument)"
                }
                return nameAndType
            }
        }
        
        private let underlyingElement: SDKDump.Element
        
        public var functionName: String {
            underlyingElement.printedName.components(separatedBy: "(").first ?? ""
        }
        
        public var arguments: [Argument] {
            var sanitizedArguments = underlyingElement.printedName
            sanitizedArguments.removeFirst(functionName.count)
            sanitizedArguments.removeFirst() // `(`
            if sanitizedArguments.hasSuffix(":)") {
                sanitizedArguments.removeLast(2) // `:)`
            } else {
                sanitizedArguments.removeLast() // `)`
            }
            
            let funcComponents = sanitizedArguments.components(separatedBy: ":")
            let inlineTypeInformation = Array(underlyingElement.children.suffix(from: 1)) // First element is the return type
            
            return funcComponents.enumerated().map { index, component in
                
                guard index < inlineTypeInformation.count else {
                    return .init(
                        name: component,
                        type: "UNKNOWN_TYPE",
                        defaultArgument: nil
                    )
                }
                
                let type = inlineTypeInformation[index]
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
        
        init?(underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .func || underlyingElement.declKind == .constructor else {
                return nil
            }
            
            self.underlyingElement = underlyingElement
        }
        
        func verboseName() -> String {
            guard let returnType else {
                // Return type is optional as enum is using it as well (Figure out what's the use is there)
                return underlyingElement.printedName
            }
            
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
    }
}
