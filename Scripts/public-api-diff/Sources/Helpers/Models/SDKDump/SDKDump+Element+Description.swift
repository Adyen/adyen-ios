//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 15/07/2024.
//

import Foundation

extension SDKDump.Element: CustomStringConvertible {
    
    var description: String {
        
        var components = descriptionPrefixComponents
        
        components += [verboseName]
        
        if let conformanceNames = conformances?.sorted().map(\.printedName), !conformanceNames.isEmpty {
            components += [": \(conformanceNames.joined(separator: ", "))"]
        }
        
        if let accessors = accessors?.map({ $0.name.lowercased() }), !accessors.isEmpty {
            components += ["{ \(accessors.joined(separator: " ")) }"]
        }
        
        return components.joined(separator: " ")
    }
    
    private var descriptionPrefixComponents: [String] {
        var components = [String]()
        
        spiGroupNames?.forEach {
            components += ["@_spi(\($0))"]
        }

        if hasDiscardableResult {
            components += ["@discardableResult"]
        }
        
        if declKind != .import {
            components += [isInternal ? "internal" : "public"]
        }
        
        if isFinal, declKind == .class {
            components += ["final"]
        }
        
        if isStatic {
            components += ["static"]
        }
        
        return components
    }
    
    var verboseName: String {
        
        guard let declKind else {
            return printedName
        }
        
        let defaultVerboseName = "\(declKind.rawValue.lowercased()) \(printedName)"
        
        switch declKind {
        case .import, .class, .struct, .enum, .protocol, .accessor, .subscriptDeclaration, .associatedType, .macro:
            return defaultVerboseName
        case .case:
            return self.asEnumCase?.description ?? defaultVerboseName
        case .var:
            return self.asVar?.description ?? defaultVerboseName
        case .constructor, .func:
            return self.asFunction?.description ?? defaultVerboseName
        case .typeAlias:
            return self.asTypeAlias?.description ?? defaultVerboseName
        }
    }
}
