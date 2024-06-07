#!/usr/bin/env xcrun swift

//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let old = CommandLine.arguments[1]
let new = CommandLine.arguments[2]

class Element: Codable, Equatable, CustomDebugStringConvertible {
    let kind: String
    let name: String
    let mangledName: String?
    let printedName: String
    let declKind: String?
    let moduleName: String?
    
    let children: [Element]?
    let spiGroupNames: [String]?
    
    var parent: Element?
    
    enum CodingKeys: String, CodingKey {
        case kind
        case name
        case printedName
        case mangledName
        case children
        case spiGroupNames = "spi_group_names"
        case declKind
        case moduleName
    }
    
    var debugDescription: String {
        var definition = ""
        spiGroupNames?.forEach {
            definition += "@_spi(\($0)) "
        }
        definition += "public "
        
        if declKind == "Var" {
            definition += "var "
        } else if declKind == "Func" {
            definition += "func "
        } else if declKind == "Import" {
            definition += "import "
        }
        
        definition += "\(printedName)"
        
        return definition
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
        
        if let moduleName = moduleName {
            sanitizedPath += [moduleName]
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

struct Change {
    enum ChangeType {
        case addition
        case removal
        case change
        
        var icon: String {
            switch self {
            case .addition:
                return "🐣"
            case .removal:
                return "💔"
            case .change:
                return "🔀"
            }
        }
    }
    
    var changeType: ChangeType
    var parentName: String
    var changeDescription: String
}

func recursiveCompare(element lhs: Element, to rhs: Element, oldFirst: Bool) -> [Change] {
    if lhs == rhs {
        return []
    }
    
    var changes = [Change]()
    
    if oldFirst, (lhs.printedName != rhs.printedName || lhs.spiGroupNames != rhs.spiGroupNames || lhs.children == rhs.children) {
        changes += [.init(changeType: .change, parentName: lhs.parentPath, changeDescription: "\(lhs) ➡️  \(rhs)")]
    }
    
    changes += lhs.children?.flatMap { lhsElement in
        if let rhsChildForName = rhs.children?.first(where: { ($0.mangledName ?? $0.name) == (lhsElement.mangledName ?? lhsElement.name) }) {
            return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
        } else {
            if oldFirst {
                return [.init(changeType: .removal, parentName: lhsElement.parentPath, changeDescription: "\(lhsElement) was removed")]
            } else {
                return [.init(changeType: .addition, parentName: lhsElement.parentPath, changeDescription: "\(lhsElement) was added")]
            }
        }
    } ?? []
    
    return changes
}

func setupRelationships(for element: Element, parent: Element?) {
    element.children?.forEach {
        $0.parent = element
        setupRelationships(for: $0, parent: element)
    }
}

func compare() throws -> Bool {
    let oldFileUrl = currentDirectory.appending(path: old)
    let newFileUrl = currentDirectory.appending(path: new)
    
    // print("Old:", oldFileUrl)
    // print("New:", newFileUrl)
    
    let decodedOldDefinition = try JSONDecoder().decode(
        Definition.self,
        from: Data(contentsOf: oldFileUrl)
    )
    
    let decodedNewDefinition = try JSONDecoder().decode(
        Definition.self,
        from: Data(contentsOf: newFileUrl)
    )
    
    if decodedOldDefinition == decodedNewDefinition {
        return true
    }
    
    setupRelationships(for: decodedOldDefinition.root, parent: nil)
    setupRelationships(for: decodedNewDefinition.root, parent: nil)
    
    let changes = recursiveCompare(
        element: decodedOldDefinition.root,
        to: decodedNewDefinition.root,
        oldFirst: true
    ) + recursiveCompare(
        element: decodedNewDefinition.root,
        to: decodedOldDefinition.root,
        oldFirst: false
    )
    
    var groupedChanges = [String: [Change]]()
    
    changes.forEach {
        groupedChanges[$0.parentName] = (groupedChanges[$0.parentName] ?? []) + [$0]
    }
    
    groupedChanges.keys.sorted().forEach { key in
        print("[\(key)]")
        groupedChanges[key]?.forEach {
            print("- \($0.changeType.icon) \($0.changeDescription)")
        }
    }
    
    return false
}

do {
    try print(compare() ? "✅ Both files are equal" : "🔀 Changes detected")
} catch {
    print(error)
}
