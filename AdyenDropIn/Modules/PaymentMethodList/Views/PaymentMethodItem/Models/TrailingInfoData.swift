//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct TrailingInfoData {

    private enum Constants {
        static let additionalLogosText = "+"
    }

    // MARK: - Properties

    internal let logoUrls: [URL]
    internal let text: String?

    // MARK: - Initializers

    internal init?(logoUrls: [URL], maxLogosCount: Int) {
        guard !logoUrls.isEmpty else { return nil }
        self.text = logoUrls.count > maxLogosCount ? Constants.additionalLogosText : nil
        self.logoUrls = Array(logoUrls.prefix(maxLogosCount))
    }
}
