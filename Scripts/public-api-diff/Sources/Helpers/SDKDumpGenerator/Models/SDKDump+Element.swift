//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump {
    
    // Element node
    class Element: Codable, Equatable, CustomDebugStringConvertible {
        
        let kind: String
        let name: String
        let mangledName: String?
        let printedName: String
        let declKind: DeclarationType?
        let isStatic: Bool
        let isLet: Bool
        
        let children: [Element]
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
            declKind: DeclarationType? = nil,
            isStatic: Bool = false,
            isLet: Bool = false,
            children: [Element] = [],
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
            self.isStatic = isStatic
            self.isLet = isLet
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
            self.children = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.children) ?? []
            self.spiGroupNames = try container.decodeIfPresent([String].self, forKey: CodingKeys.spiGroupNames)
            self.declKind = try container.decodeIfPresent(DeclarationType.self, forKey: CodingKeys.declKind)
            self.isStatic = (try? container.decode(Bool.self, forKey: CodingKeys.isStatic)) ?? false
            self.isLet = (try? container.decode(Bool.self, forKey: CodingKeys.isLet)) ?? false
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
            case isStatic = "static"
            case isLet
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
                lhs.conformances == rhs.conformances &&
                lhs.isLet == rhs.isLet &&
                lhs.isStatic == rhs.isStatic
        }
        
        var definition: String {
            var definition = ""
            spiGroupNames?.forEach {
                definition += "@_spi(\($0)) "
            }
            
            if declKind != .importDeclaration {
                definition += "public "
            }
            
            if let declAttributes, declAttributes.contains("Final"), declKind == .classDeclaration {
                definition += "final "
            }
            
            if isStatic {
                definition += "static "
            }
            
            if let declKind {
                if declKind == .constructor {
                    definition += "func "
                } else if declKind == .enumElement {
                    definition += "case "
                } else if declKind == .varDeclaration, isLet {
                    definition += "let "
                } else {
                    definition += "\(declKind.rawValue.lowercased()) "
                }
            }
            
            definition += verbosePrintedName
            
            if let conformanceNames = conformances?.map(\.printedName), !conformanceNames.isEmpty {
                definition += " : \(conformanceNames.joined(separator: ", "))"
            }
            
            if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
                definition += " { \(accessors.joined(separator: " ")) }"
            }
            
            return definition
        }
        
        var verbosePrintedName: String {
            let typeInfo = children.filter(\.isTypeInformation)
            
            if typeInfo.isEmpty {
                return printedName
            }
            
            if declKind == .typeAlias {
                return "\(printedName) = \(typeInfo.first!.verbosePrintedName)"
            }
            
            if declKind == .constructor || declKind == .function || declKind == .funcDeclaration {
                guard let returnValue = typeInfo.first?.printedName else {
                    return printedName
                }
                
                let inlineTypeInformation = typeInfo.suffix(from: 1).map(\.verbosePrintedName)
                
                var typedPrintedName: String = ""
                
                if inlineTypeInformation.isEmpty {
                    typedPrintedName = printedName
                } else {
                    let funcComponents = printedName.components(separatedBy: ":")
                    funcComponents.enumerated().forEach { index, component in
                        typedPrintedName += component
                        if index < inlineTypeInformation.count {
                            typedPrintedName += ": \(inlineTypeInformation[index])"
                        }
                        
                        if index < funcComponents.count - 2 {
                            typedPrintedName += ", "
                        }
                    }
                }
                
                return "\(typedPrintedName) -> \(returnValue)"
            }
            
            if declKind == .varDeclaration {
                guard let returnValue = typeInfo.first?.printedName else {
                    return printedName
                }
                
                return "\(printedName): \(returnValue)"
            }
            
            return printedName
        }
        
        var debugDescription: String {
            definition
        }
        
        var isSpiInternal: Bool {
            !(spiGroupNames ?? []).isEmpty
        }
        
        var isTypeInformation: Bool {
            kind == "TypeNominal" || kind == "TypeNameAlias"
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
