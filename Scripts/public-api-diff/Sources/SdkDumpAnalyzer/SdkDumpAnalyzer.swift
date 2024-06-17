//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 17/06/2024.
//

import Foundation

// MARK: - Model

enum SdkDumpAnalyzer {
    
    struct Change {
        enum ChangeType {
            case addition
            case removal
            case change
            
            var icon: String {
                switch self {
                case .addition: "❇️ "
                case .removal: "😶‍🌫️"
                case .change: "🔀"
                }
            }
        }
        
        var changeType: ChangeType
        var parentName: String
        var changeDescription: String
    }
    
    public static func diff(
        updated updatedSdkDumpFilePath: String,
        to comparisonSdkDumpFilePath: String
    ) throws -> [Change] {
        
        let updatedFileUrl = URL(filePath: updatedSdkDumpFilePath)
        let comparisonFileUrl = URL(filePath: comparisonSdkDumpFilePath)
        
        let decodedComparisonDefinition = try JSONDecoder().decode(
            SDKDump.Definition.self,
            from: Data(contentsOf: comparisonFileUrl)
        )
        
        let decodedUpdatedDefinition = try JSONDecoder().decode(
            SDKDump.Definition.self,
            from: Data(contentsOf: updatedFileUrl)
        )
        
        if decodedComparisonDefinition == decodedUpdatedDefinition {
            return []
        }
        
        setupRelationships(for: decodedComparisonDefinition.root, parent: nil)
        setupRelationships(for: decodedUpdatedDefinition.root, parent: nil)
        
        let changes = recursiveCompare(
            element: decodedComparisonDefinition.root,
            to: decodedUpdatedDefinition.root,
            oldFirst: true
        ) + recursiveCompare(
            element: decodedUpdatedDefinition.root,
            to: decodedComparisonDefinition.root,
            oldFirst: false
        )
        
        return changes
    }
}

// MARK: - Private

private extension SdkDumpAnalyzer {
    
    static func setupRelationships(for element: SDKDump.Element, parent: SDKDump.Element?) {
        element.children?.forEach {
            $0.parent = element
            setupRelationships(for: $0, parent: element)
        }
    }
    
    static func recursiveCompare(element lhs: SDKDump.Element, to rhs: SDKDump.Element, oldFirst: Bool) -> [Change] {
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
            changes += [.init(changeType: .change, parentName: lhs.parentPath, changeDescription: "`\(lhs)`\n  ➡️  `\(rhs)`")]
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
}
