//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump.Element {
    
    public var asTypeAlias: SDKDump.TypeAliasElement? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct TypeAliasElement: CustomStringConvertible {
        
        public var declaration: String { "typealias" }
        
        public var name: String { underlyingElement.printedName }
        
        public var type: String { underlyingElement.children.first?.verboseName ?? Constants.unknownType }
        
        public var description: String { "\(declaration) \(name) = \(type)" }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .typeAlias else { return nil }
            
            self.underlyingElement = underlyingElement
        }
    }
}
