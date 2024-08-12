//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/08/2024.
//

import Foundation

extension SDKDump.Element {
    
    public var asVar: SDKDump.VarElement? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct VarElement: CustomStringConvertible {
        
        public var declaration: String { underlyingElement.isLet ? "let" : "var" }
        
        public var name: String { underlyingElement.printedName }
        
        public var type: String { underlyingElement.children.first?.printedName ?? "UNKNOWN_TYPE" }
        
        public var description: String { "\(declaration) \(name): \(type)" }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .var else { return nil }
            
            self.underlyingElement = underlyingElement
        }
    }
}
