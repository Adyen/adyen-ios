//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Root node
class SDKDump: Codable, Equatable {
    let root: Element
    
    enum CodingKeys: String, CodingKey {
        case root = "ABIRoot"
    }
    
    internal init(root: Element) {
        self.root = root
        setupParentRelationships()
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.root = try container.decode(Element.self, forKey: .root)
        setupParentRelationships()
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.root, forKey: .root)
    }
    
    public static func == (lhs: SDKDump, rhs: SDKDump) -> Bool {
        lhs.root == rhs.root
    }
}

// MARK: - Convenience

private extension SDKDump {
    func setupParentRelationships() {
        root.setupParentRelationships()
    }
}

private extension SDKDump.Element {
    func setupParentRelationships(parent: SDKDump.Element? = nil) {
        self.parent = parent
        children.forEach {
            $0.setupParentRelationships(parent: self)
        }
    }
}

internal extension SDKDump {
    
    var flatDescription: String {
        var components = [String]()
        components += root.flatChildDescriptions()
        
        return components.map { component in
            return "```javascript\n\(component)\n```"
        }.joined(separator: "\n")
    }
}

private extension SDKDump.Element {
    
    func flatChildDescriptions() -> [String] {
        var definitions = [String]()
        children.forEach { child in
            if child.declKind == nil { return }
            definitions += [child.description] + child.flatChildDescriptions()
        }
        return definitions
    }
}
