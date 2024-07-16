//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump {
    
    // Element node
    class Element: Codable, Equatable, CustomDebugStringConvertible {
        
        let kind: Kind
        let name: String
        let printedName: String
        let declKind: DeclarationType?
        let isStatic: Bool
        let isLet: Bool
        let hasDefaultArg: Bool
        let isInternal: Bool
        let isThrowing: Bool
        
        let children: [Element]
        let spiGroupNames: [String]?
        let declAttributes: [String]?
        let accessors: [Element]?
        let conformances: [Conformance]?
        
        var parent: Element?
        
        internal init(
            kind: Kind,
            name: String,
            printedName: String,
            declKind: DeclarationType? = nil,
            isStatic: Bool = false,
            isLet: Bool = false,
            hasDefaultArg: Bool = false,
            isInternal: Bool = false,
            isThrowing: Bool = false,
            children: [Element] = [],
            spiGroupNames: [String]? = nil,
            declAttributes: [String]? = nil,
            accessors: [Element]? = nil,
            conformances: [Conformance]? = nil,
            parent: Element? = nil
        ) {
            self.kind = kind
            self.name = name
            self.printedName = printedName
            self.declKind = declKind
            self.isStatic = isStatic
            self.isLet = isLet
            self.hasDefaultArg = hasDefaultArg
            self.isInternal = isInternal
            self.isThrowing = isThrowing
            self.children = children
            self.spiGroupNames = spiGroupNames
            self.declAttributes = declAttributes
            self.accessors = accessors
            self.conformances = conformances
            self.parent = parent
        }
        
        required init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.kind = try container.decode(SDKDump.Kind.self, forKey: CodingKeys.kind)
            self.name = try container.decode(String.self, forKey: CodingKeys.name)
            self.printedName = try container.decode(String.self, forKey: CodingKeys.printedName)
            self.children = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.children) ?? []
            self.spiGroupNames = try container.decodeIfPresent([String].self, forKey: CodingKeys.spiGroupNames)
            self.declKind = try container.decodeIfPresent(DeclarationType.self, forKey: CodingKeys.declKind)
            self.isStatic = (try? container.decode(Bool.self, forKey: CodingKeys.isStatic)) ?? false
            self.isLet = (try? container.decode(Bool.self, forKey: CodingKeys.isLet)) ?? false
            self.hasDefaultArg = (try? container.decode(Bool.self, forKey: CodingKeys.hasDefaultArg)) ?? false
            self.isInternal = (try? container.decode(Bool.self, forKey: CodingKeys.isInternal)) ?? false
            self.isThrowing = (try? container.decode(Bool.self, forKey: CodingKeys.isThrowing)) ?? false
            self.declAttributes = try container.decodeIfPresent([String].self, forKey: CodingKeys.declAttributes)
            self.conformances = try container.decodeIfPresent([Conformance].self, forKey: CodingKeys.conformances)
            self.accessors = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.accessors)
        }
        
        func encode(to encoder: any Encoder) throws {
            var container: KeyedEncodingContainer<SDKDump.Element.CodingKeys> = encoder.container(keyedBy: SDKDump.Element.CodingKeys.self)
            try container.encode(self.kind, forKey: SDKDump.Element.CodingKeys.kind)
            try container.encode(self.name, forKey: SDKDump.Element.CodingKeys.name)
            try container.encode(self.printedName, forKey: SDKDump.Element.CodingKeys.printedName)
            try container.encode(self.children, forKey: SDKDump.Element.CodingKeys.children)
            try container.encodeIfPresent(self.spiGroupNames, forKey: SDKDump.Element.CodingKeys.spiGroupNames)
            try container.encodeIfPresent(self.declKind, forKey: SDKDump.Element.CodingKeys.declKind)
            try container.encode(self.isStatic, forKey: SDKDump.Element.CodingKeys.isStatic)
            try container.encode(self.isLet, forKey: SDKDump.Element.CodingKeys.isLet)
            try container.encode(self.hasDefaultArg, forKey: SDKDump.Element.CodingKeys.hasDefaultArg)
            try container.encode(self.isInternal, forKey: SDKDump.Element.CodingKeys.isInternal)
            try container.encode(self.isThrowing, forKey: SDKDump.Element.CodingKeys.isThrowing)
            try container.encodeIfPresent(self.declAttributes, forKey: SDKDump.Element.CodingKeys.declAttributes)
            try container.encodeIfPresent(self.conformances, forKey: SDKDump.Element.CodingKeys.conformances)
            try container.encodeIfPresent(self.accessors, forKey: SDKDump.Element.CodingKeys.accessors)
        }
        
        enum CodingKeys: String, CodingKey {
            case kind
            case name
            case printedName
            case children
            case spiGroupNames = "spi_group_names"
            case declKind
            case isStatic = "static"
            case isLet
            case hasDefaultArg
            case isInternal
            case isThrowing
            case declAttributes
            case conformances
            case accessors
        }
        
        static func == (lhs: SDKDump.Element, rhs: SDKDump.Element) -> Bool {
            lhs.kind == rhs.kind &&
                lhs.name == rhs.name &&
                lhs.printedName == rhs.printedName &&
                lhs.declKind == rhs.declKind &&
                lhs.children == rhs.children &&
                lhs.spiGroupNames == rhs.spiGroupNames &&
                lhs.declAttributes == rhs.declAttributes &&
                lhs.accessors == rhs.accessors &&
                lhs.conformances == rhs.conformances &&
                lhs.isLet == rhs.isLet &&
                lhs.hasDefaultArg == rhs.hasDefaultArg &&
                lhs.isInternal == rhs.isInternal &&
                lhs.isStatic == rhs.isStatic
        }
        
        var debugDescription: String {
            definition
        }
        
        var isSpiInternal: Bool {
            !(spiGroupNames ?? []).isEmpty
        }
        
        var isTypeInformation: Bool {
            kind.isTypeInformation
        }
        
        var parentPath: String {
            var parent = self.parent
            var path = [parent?.name]
            
            while parent != nil {
                parent = parent?.parent
                path += [parent?.name]
            }
            
            var sanitizedPath = path.compactMap { $0 }
            
            if sanitizedPath.last == "TopLevel" {
                sanitizedPath.removeLast()
            }
            
            return sanitizedPath.reversed().joined(separator: ".")
        }
    }
}

// MARK: - Convenience

extension [SDKDump.Element] {
    func firstElementMatchingName(of otherElement: Element) -> Element? {
        first(where: { $0.name == otherElement.name })
    }
}
