//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/08/2024.
//

import Foundation

extension SDKDump.Element {
    
    public var asEnumCase: SDKDump.EnumCaseElement? {
        .init(for: self)
    }
}

extension SDKDump {
    
    struct EnumCaseElement: CustomStringConvertible {
        
        public var declaration: String { "case" }
        
        public var description: String { compileDescription() }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .case else { return nil }
            
            self.underlyingElement = underlyingElement
        }
    }
}

// MARK: - Privates

private extension SDKDump.EnumCaseElement {
    
    func compileDescription() -> String {
        // TODO: Add support for: indirect
        // See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Enumerations-with-Indirection
        
        let defaultDescription = "\(declaration) \(underlyingElement.printedName)"
        
        guard let firstChild = underlyingElement.children.first else {
            return defaultDescription
        }
        
        guard let nestedFirstChild = firstChild.children.first else {
            return defaultDescription // Return type (enum type)
        }
        
        guard nestedFirstChild.children.count == 2, let associatedValue = nestedFirstChild.children.last else {
            return defaultDescription // No associated value
        }
        
        return "\(defaultDescription)\(associatedValue.printedName)"
    }
}
