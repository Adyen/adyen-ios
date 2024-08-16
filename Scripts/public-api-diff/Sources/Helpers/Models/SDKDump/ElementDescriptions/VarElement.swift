//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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
        
        public var type: String { underlyingElement.children.first?.printedName ?? Constants.unknownType }
        
        public var description: String { compileDescription() }
        
        private let underlyingElement: SDKDump.Element
        
        fileprivate init?(for underlyingElement: SDKDump.Element) {
            guard underlyingElement.declKind == .var else { return nil }
            
            self.underlyingElement = underlyingElement
        }
    }
}

// MARK: - Privates

private extension SDKDump.VarElement {
    
    func compileDescription() -> String {
        let isWeak = underlyingElement.children.first?.isWeak == true
        
        let defaultDescription = [
            isWeak ? "weak" : nil,
            underlyingElement.isLazy ? "lazy" : nil,
            declaration,
            "\(name):",
            type
        ].compactMap { $0 }.joined(separator: " ")
        
        return defaultDescription
    }
}
