//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

/// A collapsible `Section` that presents a list of multi-selectable rows.
///
/// Each row shows a title and a checkmark when selected. The disclosure header
/// shows the section title plus a summary of the current selection, so the
/// selection stays visible whether the section is collapsed or expanded.
internal struct SelectableDisclosureSection<Item, ID: Hashable>: View {
    internal let title: String
    internal let footer: String
    internal let items: [Item]
    internal let id: KeyPath<Item, ID>
    internal let summary: String
    @Binding internal var isExpanded: Bool
    internal let rowTitle: (Item) -> String
    internal let isSelected: (Item) -> Bool
    internal let onToggle: (Item) -> Void

    internal var body: some View {
        Section(footer: Text(footer)) {
            DisclosureGroup(isExpanded: $isExpanded) {
                ForEach(items, id: id) { item in
                    Button {
                        onToggle(item)
                    } label: {
                        HStack {
                            Text(rowTitle(item))
                                .foregroundColor(.primary)
                            Spacer()
                            if isSelected(item) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.primary)
                    Text(summary.isEmpty ? "None selected" : summary)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    SelectableDisclosureSectionPreviewContainer()
}

private struct SelectableDisclosureSectionPreviewContainer: View {
    private let items = ["US", "GB", "NL", "DE"]
    @State private var selection: Set<String> = ["US", "NL"]
    @State private var isExpanded = true

    var body: some View {
        List {
            SelectableDisclosureSection(
                title: "Supported Country Codes",
                footer: "Pick the countries you support.",
                items: items,
                id: \.self,
                summary: selection.sorted().joined(separator: ", "),
                isExpanded: $isExpanded,
                rowTitle: { $0 },
                isSelected: { selection.contains($0) },
                onToggle: { code in
                    if selection.contains(code) {
                        selection.remove(code)
                    } else {
                        selection.insert(code)
                    }
                }
            )
        }
    }
}
