//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - Model

enum SdkDumpAnalyzer {
    
    public static func diff(
        updated updatedSdkDumpFilePath: String,
        to comparisonSdkDumpFilePath: String
    ) throws -> [Change] {
        
        let decodedComparisonDefinition = loadDefinition(from: comparisonSdkDumpFilePath)
        let decodedUpdatedDefinition = loadDefinition(from: updatedSdkDumpFilePath)
        
        guard decodedComparisonDefinition != decodedUpdatedDefinition else {
            return []
        }
        
        guard let decodedUpdatedDefinition else {
            return [.init(changeType: .removal, parentName: "", changeDescription: "😶‍🌫️ Target was removed")]
        }
        
        guard let decodedComparisonDefinition else {
            return [.init(changeType: .removal, parentName: "", changeDescription: "😶‍🌫️ Target was added")]
        }
        
        setupRelationships(for: decodedComparisonDefinition.root, parent: nil)
        setupRelationships(for: decodedUpdatedDefinition.root, parent: nil)
        
        return recursiveCompare(
            element: decodedComparisonDefinition.root,
            to: decodedUpdatedDefinition.root,
            oldFirst: true
        ) + recursiveCompare(
            element: decodedUpdatedDefinition.root,
            to: decodedComparisonDefinition.root,
            oldFirst: false
        )
    }
}

// MARK: - Private

private extension SdkDumpAnalyzer {
    
    static func loadDefinition(from sdkDumpFilePath: String) -> SDKDump.Definition? {
        
        let fileUrl = URL(filePath: sdkDumpFilePath)
        
        return try? JSONDecoder().decode(
            SDKDump.Definition.self,
            from: Data(contentsOf: fileUrl)
        )
    }
    
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

// MARK: - Model

extension SdkDumpAnalyzer {
    
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
}
