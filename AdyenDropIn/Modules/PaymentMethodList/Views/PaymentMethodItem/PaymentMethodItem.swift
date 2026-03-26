//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI
import Foundation
import UIKit

internal struct PaymentMethodItem: Identifiable {

    internal struct TrailingInfoData {
        internal let logoUrls: [URL]
        internal let text: String?


    }

    private enum Constants {
        static let maxLogosCount = 3
        static let additionalLogosText = "+"
    }

    // MARK: - Properties

    internal let id = UUID()
    internal let title: String
    internal let subtitle: String?
    internal let iconURL: URL?
    private let trailingInfo: DisplayInformation.TrailingInfoType?
    private let logoURLProvider: LogoURLProvider
    internal let accessibilityLabel: String?
    internal let theme: AdyenTheme
    internal let selectionHandler: (() -> Void)?

    // MARK: - Initializers

    internal init(
        title: String,
        subtitle: String? = nil,
        iconURL: URL? = nil,
        trailingInfo: DisplayInformation.TrailingInfoType? = nil,
        logoURLProvider: LogoURLProvider,
        accessibilityLabel: String? = nil,
        theme: AdyenTheme,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconURL = iconURL
        self.trailingInfo = trailingInfo
        self.logoURLProvider = logoURLProvider
        self.accessibilityLabel = accessibilityLabel ?? [
            title,
            subtitle,
            self.trailingInfo?.accessibilityLabel
        ].compactMap { $0 }.joined(separator: ", ")
        self.theme = theme
        self.selectionHandler = selectionHandler
    }

    // MARK: - Internal

    internal var trailingInfoData: TrailingInfoData? {
        guard case let .logos(names, _) = trailingInfo else {
            return nil
        }

        let logoUrls = Array(names.prefix(Constants.maxLogosCount))
            .map { logoURLProvider.logoURL(withName: $0) }

        let text = names.count > Constants.maxLogosCount ? Constants.additionalLogosText : nil
        return TrailingInfoData(logoUrls: logoUrls, text: text)
    }
}
