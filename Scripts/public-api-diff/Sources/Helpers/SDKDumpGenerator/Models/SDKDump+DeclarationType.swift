//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 26/06/2024.
//

import Foundation

extension SDKDump {
    
    enum DeclarationType: String, RawRepresentable, Codable {
        
        case classDeclaration = "Class"
        case structDelcaration = "Struct"
        
        case enumDeclaration = "Enum"
        case enumElement = "EnumElement"
        
        case varDeclaration = "Var"
        case protocolDeclaration = "Protocol"
        
        case constructor = "Constructor"
        case function = "Function"
        
        case accessor = "Accessor"
        case importDeclaration = "Import"
        case typeAlias = "TypeAlias"
    }
}
