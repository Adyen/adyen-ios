//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

import Foundation

extension SDKDump {
    
    enum Kind: String, RawRepresentable, Codable {
        
        case root = "Root"
        
        case `import` = "Import"
        case `var` = "Var"
        case `func` = "Function"
        case `class` = "Class"
        case `struct` = "Struct"
        case `enum` = "Enum"
        case `case` = "EnumElement"
        case `subscript` = "Subscript"
        case `associatedtype` = "AssociatedType"
        
        case accessor = "Accessor"
        case constructor = "Constructor"
        
        case typeDeclaration = "TypeDecl"
        case typeNominal = "TypeNominal"
        case typeNameAlias = "TypeNameAlias"
        case typeAlias = "TypeAlias"
        
        case typeFunc = "TypeFunc" // TODO: Figure out what this actually does
    }
}

extension SDKDump.Kind {
    
    var isTypeInformation: Bool {
        switch self {
        case .typeNominal, .typeNameAlias: return true
        default: return false
        }
    }
}
