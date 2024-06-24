//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Allows generation of human readable output from the provided information
struct OutputGenerator {
    
    let changesPerTarget: [String: [SDKAnalyzer.Change]]
    let allTargetNames: [String]
    let oldSource: ProjectSource
    let newSource: ProjectSource
    
    init(
        changesPerTarget: [String: [SDKAnalyzer.Change]],
        allTargetNames: [String],
        oldSource: ProjectSource,
        newSource: ProjectSource
    ) {
        self.changesPerTarget = changesPerTarget
        self.allTargetNames = allTargetNames
        self.oldSource = oldSource
        self.newSource = newSource
    }
    
    /// Generates human readable output from the provided information
    func generate() -> String {
        
        let separator = "\n---"
        let changes = changeLines
        
        var lines = [
            title,
            repoInfo,
            separator
        ]
        
        if !changes.isEmpty {
            lines += changes + [separator]
        }
        
        lines += [
            analyzedModulesInfo
        ]
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - Privates

private extension OutputGenerator {
    
    var title: String {
        
        if changesPerTarget.keys.isEmpty {
            return "# ✅ No changes detected"
        }

        let totalChangeCount = changesPerTarget.totalChangeCount
        return "# 👀 \(totalChangeCount) public \(totalChangeCount == 1 ? "change" : "changes") detected"
    }
    
    var repoInfo: String { "_Comparing `\(newSource.description)` to `\(oldSource.description)`_" }
    var analyzedModulesInfo: String { "**Analyzed modules:** \(allTargetNames.joined(separator: ", "))" }
    
    var changeLines: [String] {
        var lines = [String]()
        
        changesPerTarget.keys.sorted().forEach { targetName in
            guard let changesForTarget = changesPerTarget[targetName], !changesForTarget.isEmpty else { return }
            
            if !targetName.isEmpty {
                lines.append("## `\(targetName)`")
            }
            
            var groupedChanges = [String: [SDKAnalyzer.Change]]()

            changesForTarget.forEach {
                groupedChanges[$0.parentName] = (groupedChanges[$0.parentName] ?? []) + [$0]
            }
            
            groupedChanges.keys.sorted().forEach { parent in
                guard let changes = groupedChanges[parent], !changes.isEmpty else { return }
                
                if !parent.isEmpty {
                    lines.append("### `\(parent)`")
                }
                
                changes.sorted { lhs, rhs in lhs.changeDescription < rhs.changeDescription }.forEach {
                    lines.append("- \($0.changeType.icon) \($0.changeDescription)")
                }
            }
        }
        
        return lines
    }
}
