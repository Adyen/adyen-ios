//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Configuration for the picker search screen.
package struct FormPickerConfiguration {

    /// Header shown at the top of the picker screen. `nil` → no header.
    package let header: Header?

    /// Whether the picker shows its search bar.
    package let isSearchEnabled: Bool

    package init(
        header: Header? = nil,
        isSearchEnabled: Bool = true
    ) {
        self.header = header
        self.isSearchEnabled = isSearchEnabled
    }
}

extension FormPickerConfiguration {

    /// The title/subtitle content of the picker screen header.
    package struct Header: Equatable {

        package let title: String

        package let subtitle: String?

        package init(title: String, subtitle: String? = nil) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}
