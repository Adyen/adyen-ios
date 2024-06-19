#!/usr/bin/env xcrun swift

//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

// TODO: Pass all modules at once so we can write the file out all at once
// (This also allows us to indicate in the title whether or not there were any changes)
let old = CommandLine.arguments[1]
let new = CommandLine.arguments[2]
let moduleName = CommandLine.arguments[3]

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
        definition += "public "
        
        if declAttributes?.contains("Final") == true {
            definition += "final "
        }
        
        if let declKind {
            if declKind == "Constructor" {
                definition += "func "
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

extension [Element] {
    func firstElementMatchingName(of otherElement: Element) -> Element? {
        first(where: { ($0.mangledName ?? $0.name) == (otherElement.mangledName ?? otherElement.name) })
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
                return "❇️ "
            case .removal:
                return "😶‍🌫️"
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
    
    if lhs.isSpiInternal, rhs.isSpiInternal {
        // If both elements are spi internal we can ignore them as they are not in the public interface
        return []
    }
    
    var changes = [Change]()
    
    // TODO: Add check if accessor changed (e.g. changed from get/set to get only...)
    
    if oldFirst,
       lhs.printedName != rhs.printedName ||
       lhs.spiGroupNames != rhs.spiGroupNames ||
       lhs.conformances != rhs.conformances ||
       lhs.declAttributes != rhs.declAttributes {
        // TODO: Show what exactly changed (name, spi, conformance, declAttributes, ...) as a bullet list maybe (add a `changeList` property to `Change`)
        changes += [.init(changeType: .change, parentName: lhs.parentPath, changeDescription: "`\(lhs)` ➡️  `\(rhs)`")]
    }
    
    if lhs.children == rhs.children {
        return changes
    }
    
    changes += lhs.children?.flatMap { lhsElement in
        if let rhsChildForName = rhs.children?.firstElementMatchingName(of: lhsElement) {
            return recursiveCompare(element: lhsElement, to: rhsChildForName, oldFirst: oldFirst)
        } else {
            if lhsElement.isSpiInternal { return [] }
            
            if oldFirst {
                return [.init(changeType: .removal, parentName: lhsElement.parentPath, changeDescription: "`\(lhsElement)` was removed")]
            } else {
                return [.init(changeType: .addition, parentName: lhsElement.parentPath, changeDescription: "`\(lhsElement)` was added")]
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

func compare() throws {
    let oldFileUrl = currentDirectory.appending(path: old)
    let newFileUrl = currentDirectory.appending(path: new)
    
    let decodedOldDefinition = try JSONDecoder().decode(
        Definition.self,
        from: Data(contentsOf: oldFileUrl)
    )
    
    let decodedNewDefinition = try JSONDecoder().decode(
        Definition.self,
        from: Data(contentsOf: newFileUrl)
    )
    
    if decodedOldDefinition == decodedNewDefinition {
        try persistComparison(fileContent: "## 🫧 `\(moduleName)` - No changes detected")
        return
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
    
    var fileContent = ["## 👀 `\(moduleName)`\n"]
    
    groupedChanges.keys.sorted().forEach { key in
        fileContent += ["### \(key)"]
        groupedChanges[key]?.sorted(by: { $0.changeDescription < $1.changeDescription }).forEach {
            fileContent += ["- \($0.changeType.icon) \($0.changeDescription)"]
        }
    }
    
    try persistComparison(fileContent: fileContent.joined(separator: "\n"))
}

func persistComparison(fileContent: String) throws {
    print(fileContent)
    let outputPath = currentDirectory.appendingPathComponent("api_comparison.md")
    
    if FileManager.default.fileExists(atPath: outputPath.path) {
        guard let data = (fileContent + "\n\n").data(using: String.Encoding.utf8) else { return }
        let fileHandle = try FileHandle(forWritingTo: outputPath)
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
        fileHandle.closeFile()
    } else {
        guard let data = ("# Public API Changes\n" + fileContent + "\n\n").data(using: String.Encoding.utf8) else { return }
        try data.write(to: outputPath, options: .atomicWrite)
    }
}

do {
    try compare()
} catch {
    print(error)
}
