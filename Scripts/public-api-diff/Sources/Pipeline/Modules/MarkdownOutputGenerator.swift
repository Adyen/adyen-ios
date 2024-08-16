//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Allows generation of human readable output from the provided information
struct MarkdownOutputGenerator: OutputGenerating {
    
    /// Generates human readable output from the provided information
    func generate(
        from changesPerTarget: [String: [Change]],
        allTargets: [String],
        oldSource: ProjectSource,
        newSource: ProjectSource
    ) -> String {
        
        let separator = "\n---"
        let changes = Self.changeLines(changesPerModule: changesPerTarget)
        
        var lines = [
            Self.title(changesPerTarget: changesPerTarget),
            Self.repoInfo(oldSource: oldSource, newSource: newSource),
            separator
        ]
        
        if !changes.isEmpty {
            lines += changes + [separator]
        }
        
        lines += [
            Self.analyzedModulesInfo(allTargets: allTargets)
        ]
        
        return lines.joined(separator: "\n")
    }
}

// MARK: - Privates

private extension MarkdownOutputGenerator {
    
    static func title(changesPerTarget: [String: [Change]]) -> String {
        
        if changesPerTarget.keys.isEmpty {
            return "# ✅ No changes detected"
        }
        
        let totalChangeCount = changesPerTarget.totalChangeCount
        return "# 👀 \(totalChangeCount) public \(totalChangeCount == 1 ? "change" : "changes") detected"
    }
    
    static func repoInfo(oldSource: ProjectSource, newSource: ProjectSource) -> String {
        "_Comparing `\(newSource.description)` to `\(oldSource.description)`_"
    }
    
    static func analyzedModulesInfo(allTargets: [String]) -> String {
        "**Analyzed targets:** \(allTargets.joined(separator: ", "))"
    }
    
    static func changeLines(changesPerModule: [String: [Change]]) -> [String] {
        var lines = [String]()
        
        changesPerModule.keys.sorted().forEach { targetName in
            guard let changesForTarget = changesPerModule[targetName], !changesPerModule.isEmpty else { return }
            
            if !targetName.isEmpty {
                lines.append("## `\(targetName)`")
            }
            
            var groupedChanges = [String: [Change]]()
            
            changesForTarget.forEach {
                groupedChanges[$0.parentName] = (groupedChanges[$0.parentName] ?? []) + [$0]
            }
            
            groupedChanges.keys.sorted().forEach { parent in
                guard let changes = groupedChanges[parent], !changes.isEmpty else { return }
                
                if !parent.isEmpty {
                    lines.append("### `\(parent)`")
                }
                
                let additionLines = changeSectionLines(
                    title: "#### ❇️ Added",
                    changes: changes.filter(\.changeType.isAddition)
                )
                let changeLines = changeSectionLines(
                    title: "#### 🔀 Changed",
                    changes: changes.filter(\.changeType.isChange)
                )
                let removalLines = changeSectionLines(
                    title: "#### 😶‍🌫️ Removed",
                    changes: changes.filter(\.changeType.isRemoval)
                )
                
                if !additionLines.isEmpty { lines += additionLines }
                if !changeLines.isEmpty { lines += changeLines }
                if !removalLines.isEmpty { lines += removalLines }
            }
        }
        
        return lines
    }
}

private extension MarkdownOutputGenerator {
    
    static func changeSectionLines(title: String, changes: [Change]) -> [String] {
        if changes.isEmpty { return [] }

        var lines = [title]
        changes.sorted { lhs, rhs in description(for: lhs) < description(for: rhs) }.forEach {
            // We're using `javascript` as it produces the nicest looking markdown output on Github
            // `swift` is available but sometimes produces unexpected syntax highlighting
            lines.append("```javascript")
            lines.append(description(for: $0))

            if !$0.listOfChanges.isEmpty {
                lines.append("")
                lines.append("/**")
                lines.append("Changes:")
                $0.listOfChanges.forEach {
                    lines.append("- \($0)")
                }
                lines.append("*/")
            }

            lines.append("```")
        }
        return lines
    }
    
    static func description(for change: Change) -> String {
        switch change.changeType {
        case let .addition(description):
            return description
        case let .removal(description):
            return description
        case let .change(before, after):
            return "// From\n\(before)\n\n// To\n\(after)"
        }
    }
}
