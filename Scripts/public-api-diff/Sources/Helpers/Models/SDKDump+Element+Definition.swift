//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

import Foundation

extension SDKDump.Element {
    
    var definition: String {
        var definition = ""
        spiGroupNames?.forEach {
            definition += "@_spi(\($0)) "
        }
        if let declAttributes, declAttributes.contains("DiscardableResult") {
            definition += "@discardableResult "
        }
        
        if declKind != .import {
            definition += "public "
        }
        
        if let declAttributes, declAttributes.contains("Final"), declKind == .class {
            definition += "final "
        }
        
        if isStatic {
            definition += "static "
        }
        
        if let declKind {
            if declKind == .constructor {
                definition += "func "
            } else if declKind == .case {
                definition += "case "
            } else if declKind == .var, isLet {
                definition += "let "
            } else {
                definition += "\(declKind.rawValue.lowercased()) "
            }
        }
        
        definition += verbosePrintedName
        
        if let conformanceNames = conformances?.sorted().map(\.printedName), !conformanceNames.isEmpty {
            definition += " : \(conformanceNames.joined(separator: ", "))"
        }
        
        if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
            definition += " { \(accessors.joined(separator: " ")) }"
        }
        
        return definition
    }
    
    var verbosePrintedName: String {
        let typeInfo = children.filter(\.isTypeInformation)
        
        if typeInfo.isEmpty {
            return printedName
        }
        
        if declKind == .typeAlias {
            return "\(printedName) = \(typeInfo.first!.verbosePrintedName)"
        }
        
        if declKind == .constructor || declKind == .func {
            guard let returnValue = typeInfo.first?.printedName else {
                return printedName
            }
            
            let inlineTypeInformation = Array(typeInfo.suffix(from: 1))
            
            var typedPrintedName = ""
            
            if inlineTypeInformation.isEmpty {
                typedPrintedName = printedName
            } else {
                let funcComponents = printedName.components(separatedBy: ":")
                funcComponents.enumerated().forEach { index, component in
                    typedPrintedName += component
                    if index < inlineTypeInformation.count {
                        let type = inlineTypeInformation[index]
                        typedPrintedName += ": \(type.verbosePrintedName)"
                        if type.hasDefaultArg {
                            typedPrintedName += " = $DEFAULT_ARG"
                        }
                    }
                    
                    if index < funcComponents.count - 2 {
                        typedPrintedName += ", "
                    }
                }
            }
            
            return "\(typedPrintedName) -> \(returnValue == "()" ? "Void" : returnValue)"
        }
        
        if declKind == .var {
            guard let returnValue = typeInfo.first?.printedName else {
                return printedName
            }
            
            return "\(printedName): \(returnValue)"
        }
        
        return printedName
    }
}
