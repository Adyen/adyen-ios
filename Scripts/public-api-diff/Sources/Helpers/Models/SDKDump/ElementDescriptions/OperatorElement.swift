//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 14/08/2024.
//

import Foundation

extension SDKDump.Element {
    
    public var asOperator: SDKDump.OperatorElement? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct OperatorElement: CustomStringConvertible {
        
        public var declaration: String { "operator" }
        
        public var name: String { underlyingElement.printedName }
        
        public var description: String { "\(declaration) \(name)" }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .infixOperator || underlyingElement.declKind == .postfixOperator || underlyingElement.declKind == .prefixOperator else { return nil }
            
            self.underlyingElement = underlyingElement
        }
    }
}
