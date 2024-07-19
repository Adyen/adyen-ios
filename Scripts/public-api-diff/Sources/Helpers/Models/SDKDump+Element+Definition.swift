//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

import Foundation

extension SDKDump.Element {
    
    var definition: String {
        var components = [String]()
        spiGroupNames?.forEach {
            components += ["@_spi(\($0))"]
        }
        if let declAttributes, declAttributes.contains("DiscardableResult") {
            components += ["@discardableResult"]
        }
        
        if declKind != .import {
            components += ["public"]
        }
        
        if let declAttributes, declAttributes.contains("Final"), declKind == .class {
            components += ["final"]
        }
        
        if isStatic {
            components += ["static"]
        }
        
        if let declKind {
            if declKind == .constructor {
                components += ["func"]
            } else if declKind == .case {
                components += ["case"]
            } else if declKind == .var, isLet {
                components += ["let"]
            } else {
                components += ["\(declKind.rawValue.lowercased())"]
            }
        }
        
        components += [verbosePrintedName]
        
        if let conformanceNames = conformances?.sorted().map(\.printedName), !conformanceNames.isEmpty {
            components += [": \(conformanceNames.joined(separator: ", "))"]
        }
        
        if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
            components += ["{ \(accessors.joined(separator: " ")) }"]
        }
        
        return components.joined(separator: " ")
    }
    
    var verbosePrintedName: String {
        
        guard let declKind else {
            return printedName
        }
        
        switch declKind {
        case .import:
            return printedName
        case .class:
            return printedName
        case .struct:
            return printedName
        case .enum:
            return printedName
        case .case:
            return caseDefinition()
        case .var:
            return varDefinition()
        case .protocol:
            return printedName
        case .constructor, .func:
            return funcDefinition()
        case .accessor:
            return printedName
        case .typeAlias:
            return typeAliasDefinition()
        case .subscriptDeclaration:
            return printedName
        case .associatedType:
            return printedName
        case .macro:
            return printedName
        }
    }
}

private extension SDKDump.Element {
    
    func typeAliasDefinition() -> String {
        guard let alias = children.first?.verbosePrintedName else {
            return printedName
        }
        
        return "\(printedName) = \(alias)"
    }
    
    func varDefinition() -> String {
        guard let returnValue = children.first?.printedName else {
            return printedName
        }
        
        return "\(printedName): \(returnValue)"
    }
    
    func caseDefinition() -> String {
        guard let firstChild = children.first else {
            return printedName
        }
        
        guard let nestedFirstChild = firstChild.children.first else {
            return printedName // Return type (enum type)
        }
        
        guard nestedFirstChild.children.count == 2, let associatedValue = nestedFirstChild.children.last else { 
            return printedName // No associated value
        }
        
        return printedName + associatedValue.printedName
    }
    
    func funcDefinition() -> String {
        guard let returnValue = children.first?.printedName else {
            return printedName
        }
        
        let inlineTypeInformation = Array(children.suffix(from: 1))
        let typedPrintedName: String
        
        if inlineTypeInformation.isEmpty {
            typedPrintedName = printedName
        } else {
            let funcComponents = printedName.components(separatedBy: ":")
            
            var typedName = ""
            funcComponents.enumerated().forEach { index, component in
                typedName += component
                
                guard index < inlineTypeInformation.count else { return }
                    
                let type = inlineTypeInformation[index]
                typedName += ": \(type.verbosePrintedName)"
                
                if type.hasDefaultArg {
                    typedName += " = $DEFAULT_ARG"
                }
                
                if index < funcComponents.count - 2 {
                    typedName += ", "
                }
            }
            typedPrintedName = typedName
        }
        
        let components: [String?] = [
            typedPrintedName,
            isThrowing ? "throws" : nil,
            "->",
            returnValue == "()" ? "Swift.Void" : returnValue
        ]
        
        return components
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
