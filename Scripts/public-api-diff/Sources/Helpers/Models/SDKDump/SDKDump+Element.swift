//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SDKDump {
    
    /// Generic element node
    ///
    /// The generic ``Element`` node contains all information from the abi.json 
    /// which - due to it's recursive (children) nature leads to optional fields that are only available in a specific context.
    class Element: Codable, Equatable {
        
        let kind: Kind
        let name: String
        let printedName: String
        let declKind: DeclarationKind?
        /// Indicates whether or not a property / function is static
        let isStatic: Bool
        /// Indicates whether or not a variable is a `let` (or a `var`)
        let isLet: Bool
        /// Indicates whether or not a function argument has a default value
        let hasDefaultArg: Bool
        /// Whether or not an element is marked as `package` or `internal` (only observed when using an abi.json from a binary framework)
        let isInternal: Bool
        /// Whether or not a class is marked as `open`
        let isOpen: Bool
        /// Indicates whether or not a function is throwing
        let isThrowing: Bool
        /// Indicates whether or not an init is a `convenience` or a `designated` initializer
        let initKind: String?
        /// Contains the generic signature of the element
        let genericSig: String?
        /// Defines the ownership of the parameter value (e.g. inout)
        let paramValueOwnership: String?
        /// Defines whether or not the function is mutating/nonmutating
        let funcSelfKind: String?
        /// The `children` of an ``Element`` which can contain a return value,
        /// function arguments and other context related information
        let children: [Element]
        /// The `@_spi` group names
        let spiGroupNames: [String]?
        /// Additional context related information about the element
        /// (e.g. `DiscardableResult`, `Objc`,  `Dynamic`, ...)
        let declAttributes: [String]?
        /// The accessors of the element (in the context of a protocol definition)
        let accessors: [Element]?
        /// The conformances the ``Element`` conforms to
        let conformances: [Conformance]?
        
        /// The parent element to the ``Element`` to traverse back to the hierarchy
        /// Is set manually within the ``setupParentRelationships(parent:)``
        var parent: Element?
        
        internal init(
            kind: Kind,
            name: String,
            printedName: String,
            declKind: DeclarationKind? = nil,
            isStatic: Bool = false,
            isLet: Bool = false,
            hasDefaultArg: Bool = false,
            isInternal: Bool = false,
            isThrowing: Bool = false,
            isOpen: Bool = false,
            initKind: String? = nil,
            genericSig: String? = nil,
            paramValueOwnership: String? = nil,
            funcSelfKind: String? = nil,
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
            self.isOpen = isOpen
            self.children = children
            self.spiGroupNames = spiGroupNames
            self.declAttributes = declAttributes
            self.accessors = accessors
            self.conformances = conformances
            self.parent = parent
            self.initKind = initKind
            self.genericSig = genericSig
            self.paramValueOwnership = paramValueOwnership
            self.funcSelfKind = funcSelfKind
        }
        
        required init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.kind = try container.decode(SDKDump.Kind.self, forKey: CodingKeys.kind)
            self.name = try container.decode(String.self, forKey: CodingKeys.name)
            self.printedName = try container.decode(String.self, forKey: CodingKeys.printedName)
            self.children = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.children) ?? []
            self.spiGroupNames = try container.decodeIfPresent([String].self, forKey: CodingKeys.spiGroupNames)
            self.declKind = try container.decodeIfPresent(DeclarationKind.self, forKey: CodingKeys.declKind)
            self.isStatic = (try? container.decode(Bool.self, forKey: CodingKeys.isStatic)) ?? false
            self.isLet = (try? container.decode(Bool.self, forKey: CodingKeys.isLet)) ?? false
            self.hasDefaultArg = (try? container.decode(Bool.self, forKey: CodingKeys.hasDefaultArg)) ?? false
            self.isInternal = (try? container.decode(Bool.self, forKey: CodingKeys.isInternal)) ?? false
            self.isThrowing = (try? container.decode(Bool.self, forKey: CodingKeys.isThrowing)) ?? false
            self.isOpen = try container.decodeIfPresent(Bool.self, forKey: CodingKeys.isOpen) ?? false
            self.declAttributes = try container.decodeIfPresent([String].self, forKey: CodingKeys.declAttributes)
            self.conformances = try container.decodeIfPresent([Conformance].self, forKey: CodingKeys.conformances)
            self.accessors = try container.decodeIfPresent([SDKDump.Element].self, forKey: CodingKeys.accessors)
            self.initKind = try container.decodeIfPresent(String.self, forKey: CodingKeys.initKind)
            self.genericSig = try container.decodeIfPresent(String.self, forKey: CodingKeys.genericSig)
            self.paramValueOwnership = try container.decodeIfPresent(String.self, forKey: CodingKeys.paramValueOwnership)
            self.funcSelfKind = try container.decodeIfPresent(String.self, forKey: CodingKeys.funcSelfKind)
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
            try container.encode(self.isOpen, forKey: SDKDump.Element.CodingKeys.isOpen)
            try container.encodeIfPresent(self.declAttributes, forKey: SDKDump.Element.CodingKeys.declAttributes)
            try container.encodeIfPresent(self.conformances, forKey: SDKDump.Element.CodingKeys.conformances)
            try container.encodeIfPresent(self.accessors, forKey: SDKDump.Element.CodingKeys.accessors)
            try container.encodeIfPresent(self.initKind, forKey: SDKDump.Element.CodingKeys.initKind)
            try container.encodeIfPresent(self.genericSig, forKey: SDKDump.Element.CodingKeys.genericSig)
            try container.encodeIfPresent(self.paramValueOwnership, forKey: SDKDump.Element.CodingKeys.paramValueOwnership)
            try container.encodeIfPresent(self.funcSelfKind, forKey: SDKDump.Element.CodingKeys.funcSelfKind)
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
            case isThrowing = "throwing"
            case declAttributes
            case conformances
            case accessors
            case initKind = "init_kind"
            case genericSig
            case paramValueOwnership
            case funcSelfKind
            case isOpen
        }
        
        static func == (lhs: SDKDump.Element, rhs: SDKDump.Element) -> Bool {
            lhs.kind == rhs.kind &&
            lhs.name == rhs.name &&
            lhs.printedName == rhs.printedName &&
            lhs.declKind == rhs.declKind &&
            lhs.isStatic == rhs.isStatic &&
            lhs.isLet == rhs.isLet &&
            lhs.hasDefaultArg == rhs.hasDefaultArg &&
            lhs.isInternal == rhs.isInternal &&
            lhs.isThrowing == rhs.isThrowing &&
            lhs.children == rhs.children &&
            lhs.spiGroupNames == rhs.spiGroupNames &&
            lhs.declAttributes == rhs.declAttributes &&
            lhs.accessors == rhs.accessors &&
            lhs.conformances == rhs.conformances &&
            lhs.initKind == rhs.initKind &&
            lhs.genericSig == rhs.genericSig &&
            lhs.paramValueOwnership == rhs.paramValueOwnership &&
            lhs.funcSelfKind == rhs.funcSelfKind &&
            // Only comparing the printedName of the parent as using the whole element would lead to an infinite loop
            lhs.parent?.printedName == rhs.parent?.printedName
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension SDKDump.Element: CustomDebugStringConvertible {
    
    var debugDescription: String {
        description
    }
}

// MARK: - Convenience

extension SDKDump.Element {
    
    var isSpiInternal: Bool {
        !(spiGroupNames ?? []).isEmpty
    }
    
    var isFinal: Bool {
        guard declKind == .class else { return false }
        return (declAttributes ?? []).contains("Final")
    }
    
    var hasDiscardableResult: Bool {
        (declAttributes ?? []).contains("DiscardableResult")
    }
    
    var isObjcAccessible: Bool {
        (declAttributes ?? []).contains("ObjC")
    }
    
    var isOverride: Bool {
        (declAttributes ?? []).contains("Override")
    }
    
    var isDynamic: Bool {
        (declAttributes ?? []).contains("Dynamic")
    }
    
    var isLazy: Bool {
        (declAttributes ?? []).contains("Lazy")
    }
    
    var isRequired: Bool {
        (declAttributes ?? []).contains("Required")
    }
    
    var isPrefix: Bool {
        (declAttributes ?? []).contains("Prefix")
    }
    
    var isPostfix: Bool {
        (declAttributes ?? []).contains("Postfix")
    }
    
    var isInfix: Bool {
        (declAttributes ?? []).contains("Infix")
    }
    
    var isInlinable: Bool {
        (declAttributes ?? []).contains("Inlinable")
    }
    
    var isIndirect: Bool {
        (declAttributes ?? []).contains("Indirect")
    }
    
    var isTypeInformation: Bool {
        kind.isTypeInformation
    }
    
    var isConvenienceInit: Bool {
        initKind == "Convenience"
    }
    
    var isWeak: Bool {
        name == "WeakStorage"
    }
    
    var isMutating: Bool {
        funcSelfKind == "Mutating"
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
