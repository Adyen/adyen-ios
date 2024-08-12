//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump {
    
    enum DeclarationKind: String, RawRepresentable, Codable {
        
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
