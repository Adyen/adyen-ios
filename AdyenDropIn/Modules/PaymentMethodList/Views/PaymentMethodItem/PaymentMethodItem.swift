//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import UIKit

internal struct PaymentMethodItem: Identifiable {

    // MARK: - Properties

    internal let id = UUID()
    internal let title: String
    internal let subtitle: String?
    internal let iconURL: URL?
    private let trailingInfo: DisplayInformation.TrailingInfoType?
    private let logoURLProvider: LogoURLProvider
    internal let accessibilityLabel: String?
    internal let theme: CheckoutTheme
    internal let selectionHandler: (() -> Void)?

    // MARK: - Initializers

    internal init(
        title: String,
        subtitle: String? = nil,
        iconURL: URL? = nil,
        trailingInfo: DisplayInformation.TrailingInfoType? = nil,
        logoURLProvider: LogoURLProvider,
        accessibilityLabel: String? = nil,
        theme: CheckoutTheme,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconURL = iconURL
        self.trailingInfo = trailingInfo
        self.logoURLProvider = logoURLProvider
        self.accessibilityLabel = accessibilityLabel ?? [
            title,
            subtitle
        ].compactMap { $0 }.joined(separator: ", ")
        self.theme = theme
        self.selectionHandler = selectionHandler
    }

    // MARK: - Internal

    internal var trailingInfoData: TrailingInfoData? {
        guard case let .logos(names, _) = trailingInfo else {
            return nil
        }

        let logoUrls = names.map { logoURLProvider.logoURL(withName: $0) }
        return TrailingInfoData(logoUrls: logoUrls)
    }
}
