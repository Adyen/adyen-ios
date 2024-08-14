//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

import Foundation

extension SDKDump.Element: CustomStringConvertible {
    
    var description: String {
        
        var components = genericPrefixes
        components += [verboseName]
        components += genericSuffixes

        return components.joined(separator: " ")
    }
    
    var verboseName: String {
        
        guard let declKind else { return printedName }
        
        let defaultVerboseName = [
            "\(declKind.rawValue.lowercased()) \(printedName)",
            genericSig
        ].compactMap { $0 }.joined()
        
        switch declKind {
        case .import, .enum, .protocol, .accessor, .macro, .associatedType, .class, .struct:
            return defaultVerboseName
        case .case:
            return self.asEnumCase?.description ?? defaultVerboseName
        case .var:
            return self.asVar?.description ?? defaultVerboseName
        case .constructor, .func, .subscriptDeclaration:
            return self.asFunction?.description ?? defaultVerboseName
        case .typeAlias:
            return self.asTypeAlias?.description ?? defaultVerboseName
        case .infixOperator, .prefixOperator, .postfixOperator:
            return self.asOperator?.description ?? defaultVerboseName
        }
    }
}

private extension SDKDump.Element {
    
    private var genericPrefixes: [String] {
        var components = [String]()
        
        // TODO: Add support for: unowned, ...
        // See: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations#Declaration-Modifiers
        
        spiGroupNames?.forEach { components += ["@_spi(\($0))"] }
        if hasDiscardableResult { components += ["@discardableResult"] }
        if isObjcAccessible { components += ["@objc"] }
        if isInlinable { components += ["@inlinable"]}
        
        if isOverride { components += ["override"] }
        if declKind != .import {
            if isOpen {
                components += ["open"]
            } else if isInternal {
                components += ["internal"]
            } else {
                components += ["public"]
            }
        }
        if isFinal { components += ["final"] }
        if isIndirect { components += ["indirect"] }
        if isRequired { components += ["required"] }
        if isStatic { components += ["static"] }
        if isConvenienceInit { components += ["convenience"] }
        if isDynamic { components += ["dynamic"] }
        if isPrefix  { components += ["prefix"] }
        if isPostfix  { components += ["postfix"] }
        if isInfix  { components += ["infix"] }

        return components
    }
    
    var genericSuffixes: [String] {
        
        var components = [String]()
        
        if let conformanceNames = conformances?.sorted().map(\.printedName), !conformanceNames.isEmpty {
            components += [": \(conformanceNames.joined(separator: ", "))"]
        }
        
        if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
            components += ["{ \(accessors.joined(separator: " ")) }"]
        }
        
        return components
    }
}
