//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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
        case funcDeclaration = "Func"
        
        case constructor = "Constructor"
        case function = "Function"
        
        case accessor = "Accessor"
        case importDeclaration = "Import"
        case typeAlias = "TypeAlias"
        
        case subscriptDeclaration = "Subscript"
        case associatedType = "AssociatedType"
    }
}
