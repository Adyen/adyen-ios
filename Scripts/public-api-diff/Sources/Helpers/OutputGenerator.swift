//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 18/06/2024.
//

import Foundation

enum OutputGenerator {
    
    static func generate(
        from changesPerTarget: [String: [SDKAnalyzer.Change]],
        allTargetNames: [String],
        oldSource: ProjectSource,
        newSource: ProjectSource
    ) -> String {
        
        let separator = "\n---"
        let repoInfo = "_Comparing `\(newSource.rawValue)` to `\(oldSource.rawValue)`_"
        let analyzedModulesInfo = "**Analyzed modules:** \(allTargetNames.joined(separator: ", "))"
        
        if changesPerTarget.keys.isEmpty {
            return [
                "# ✅ No changes detected",
                repoInfo,
                separator,
                analyzedModulesInfo
            ].joined(separator: "\n")
        }
        
        // TODO: Log the change count
        var lines = [
            "# 💔 Breaking changes detected",
            repoInfo,
            separator
        ]
        
        changesPerTarget.keys.sorted().forEach { key in
            guard let changes = changesPerTarget[key], !changes.isEmpty else { return }
            
            if !key.isEmpty {
                lines.append("## `\(key)`")
            }
            
            var groupedChanges = [String: [SDKAnalyzer.Change]]()

            changes.forEach {
                groupedChanges[$0.parentName] = (groupedChanges[$0.parentName] ?? []) + [$0]
            }
            
            groupedChanges.keys.sorted().forEach { parent in
                if let changes = groupedChanges[parent], !changes.isEmpty {
                    if !parent.isEmpty {
                        lines.append("### `\(parent)`")
                    }
                    groupedChanges[parent]?.forEach {
                        lines.append("- \($0.changeType.icon) \($0.changeDescription)")
                    }
                }
            }
        }
        
        lines += [
            separator,
            analyzedModulesInfo
        ]
        
        return lines.joined(separator: "\n")
    }
}
