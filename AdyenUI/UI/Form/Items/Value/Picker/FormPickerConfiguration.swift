//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Configuration for the picker search screen.
package struct FormPickerConfiguration {

    /// The title of the picker screen.
    package let title: String

    /// The subtitle of the picker screen.
    package let subtitle: String?

    /// Whether the picker shows its search bar.
    package let isSearchEnabled: Bool

    package init(title: String, subtitle: String? = nil, isSearchEnabled: Bool = true) {
        self.title = title
        self.subtitle = subtitle
        self.isSearchEnabled = isSearchEnabled
    }
}
