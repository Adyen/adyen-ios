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
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.root = try container.decode(Element.self, forKey: .root)
    }
    
    public static func == (lhs: SDKDump, rhs: SDKDump) -> Bool {
        lhs.root == rhs.root
    }
}

// MARK: - Conformance

extension SDKDump.Element {
    
    // Protocol conformance node
    struct Conformance: Codable, Equatable {
        var printedName: String
        
        enum CodingKeys: String, CodingKey {
            case printedName
        }
    }
}

// MARK: - Element

extension SDKDump {
    
    // Element node
    class Element: Codable, Equatable, CustomDebugStringConvertible {
        
        let kind: String
        let name: String
        let mangledName: String?
        let printedName: String
        let declKind: String?
        
        let children: [Element]?
        let spiGroupNames: [String]?
        let declAttributes: [String]?
        let accessors: [Element]?
        let conformances: [Conformance]?
        
        var parent: Element?
        
        internal init(
            kind: String,
            name: String,
            mangledName: String? = nil,
            printedName: String,
            declKind: String? = nil,
            children: [Element]? = nil,
            spiGroupNames: [String]? = nil,
            declAttributes: [String]? = nil,
            accessors: [Element]? = nil,
            conformances: [Conformance]? = nil,
            parent: Element? = nil
        ) {
            self.kind = kind
            self.name = name
            self.mangledName = mangledName
            self.printedName = printedName
            self.declKind = declKind
            self.children = children
            self.spiGroupNames = spiGroupNames
            self.declAttributes = declAttributes
            self.accessors = accessors
            self.conformances = conformances
            self.parent = parent
        }
        
        required init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.kind = try container.decode(String.self, forKey: CodingKeys.kind)
            self.name = try container.decode(String.self, forKey: CodingKeys.name)
            self.printedName = try container.decode(String.self, forKey: CodingKeys.printedName)
            self.mangledName = try container.decodeIfPresent(String.self, forKey: CodingKeys.mangledName)
            self.children = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.children)
            self.spiGroupNames = try container.decodeIfPresent([String].self, forKey: CodingKeys.spiGroupNames)
            self.declKind = try container.decodeIfPresent(String.self, forKey: CodingKeys.declKind)
            self.declAttributes = try container.decodeIfPresent([String].self, forKey: CodingKeys.declAttributes)
            self.conformances = try container.decodeIfPresent([Conformance].self, forKey: CodingKeys.conformances)
            self.accessors = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.accessors)
        }
        
        enum CodingKeys: String, CodingKey {
            case kind
            case name
            case printedName
            case mangledName
            case children
            case spiGroupNames = "spi_group_names"
            case declKind
            case declAttributes
            case conformances
            case accessors
        }
        
        static func == (lhs: SDKDump.Element, rhs: SDKDump.Element) -> Bool {
            lhs.kind == rhs.kind &&
                lhs.name == rhs.name &&
                lhs.mangledName == rhs.mangledName &&
                lhs.printedName == rhs.printedName &&
                lhs.declKind == rhs.declKind &&
                lhs.children == rhs.children &&
                lhs.spiGroupNames == rhs.spiGroupNames &&
                lhs.declAttributes == rhs.declAttributes &&
                lhs.accessors == rhs.accessors &&
                lhs.conformances == rhs.conformances
        }
        
        var definition: String {
            var definition = ""
            spiGroupNames?.forEach {
                definition += "@_spi(\($0)) "
            }
            
            if declKind != "Import" {
                definition += "public "
            }
            
            if let declAttributes, declAttributes.contains("Final"), declKind == "Class" {
                definition += "final "
            }
            
            if let declKind {
                if declKind == "Constructor" {
                    definition += "func "
                } else if declKind == "EnumElement" {
                    definition += "case "
                } else {
                    definition += "\(declKind.lowercased()) "
                }
            }
            
            definition += "\(printedName)"
            
            if let conformanceNames = conformances?.map(\.printedName), !conformanceNames.isEmpty {
                definition += " : \(conformanceNames.joined(separator: ", "))"
            }
            
            if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
                definition += " { \(accessors.joined(separator: " ")) }"
            }
            
            return definition
        }
        
        var debugDescription: String {
            definition
        }
        
        var isSpiInternal: Bool {
            !(spiGroupNames ?? []).isEmpty
        }
        
        var isTypeInformation: Bool {
            kind == "TypeNominal"
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

extension [SDKDump.Element] {
    func firstElementMatchingName(of otherElement: Element) -> Element? {
        first(where: { $0.name == otherElement.name })
    }
}
