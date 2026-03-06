//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal struct PaymentMethodItem: Identifiable {

    internal let id = UUID()
    internal let title: String
    internal let subtitle: String?
    internal let iconURL: URL?
    internal let accessibilityLabel: String?
    internal let selectionHandler: (() -> Void)?
    
    internal init(
        title: String,
        subtitle: String? = nil,
        iconURL: URL? = nil,
        accessibilityLabel: String? = nil,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconURL = iconURL
        self.accessibilityLabel = accessibilityLabel
        self.selectionHandler = selectionHandler
    }
}
