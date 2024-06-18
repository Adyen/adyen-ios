//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDumper {
    
    struct Conformance: Codable, Equatable {
        var printedName: String
        
        enum CodingKeys: String, CodingKey {
            case printedName
        }
    }

    class Element: Codable, Equatable, CustomDebugStringConvertible {
        let kind: String
        let name: String
        let mangledName: String?
        let printedName: String
        let declKind: String?
        
        let children: [Element]?
        let spiGroupNames: [String]?
        let declAttributes: [String]?
        let conformances: [Conformance]?
        
        var parent: Element?
        
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
        }
        
        var debugDescription: String {
            var definition = ""
            spiGroupNames?.forEach {
                definition += "@_spi(\($0)) "
            }
            
            if declKind != "Import" {
                definition += "public "
            }
            
            if declAttributes?.contains("Final") == true {
                definition += "final "
            }
            
            if let declKind {
                if declKind == "Constructor" {
                    definition += "func "
                } else if declKind == "enumelement" {
                    definition += "case "
                } else {
                    definition += "\(declKind.lowercased()) "
                }
            }
            
            definition += "\(printedName)"
            
            if let conformanceNames = conformances?.map(\.printedName), !conformanceNames.isEmpty {
                definition += " : \(conformanceNames.joined(separator: ", "))"
            }
            
            return definition
        }
        
        var isSpiInternal: Bool {
            !(spiGroupNames ?? []).isEmpty
        }
        
        public static func == (lhs: Element, rhs: Element) -> Bool {
            lhs.mangledName == rhs.mangledName
                && lhs.children == rhs.children
                && lhs.spiGroupNames == rhs.spiGroupNames
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

    class Definition: Codable, Equatable {
        let root: Element
        
        enum CodingKeys: String, CodingKey {
            case root = "ABIRoot"
        }
        
        public static func == (lhs: Definition, rhs: Definition) -> Bool {
            lhs.root == rhs.root
        }
    }
}

extension [SDKDumper.Element] {
    func firstElementMatchingName(of otherElement: Element) -> Element? {
        first(where: { ($0.mangledName ?? $0.name) == (otherElement.mangledName ?? otherElement.name) })
    }
}
