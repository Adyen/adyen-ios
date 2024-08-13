//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump {
    
    enum DeclarationKind: String, RawRepresentable, Codable {
        
        // TODO: Add support for: Actor, Operator, PrecedenceGroup,
        // See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Actor-Declaration
        // See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Operator-Declaration
        // See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Precedence-Group-Declaration
        
        case `import` = "Import"
        case `class` = "Class"
        case `struct` = "Struct"
        case `enum` = "Enum"
        case `case` = "EnumElement"
        case `var` = "Var"
        case `func` = "Func"
        case `protocol` = "Protocol"
        
        case constructor = "Constructor"
        case accessor = "Accessor"
        
        case typeAlias = "TypeAlias"
        
        case subscriptDeclaration = "Subscript"
        case associatedType = "AssociatedType"
        
        case macro = "Macro"
    }
}
