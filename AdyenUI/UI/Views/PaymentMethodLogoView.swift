//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

/// SwiftUI wrapper around the shared `AdyenUI.PaymentLogoView` so all logo styling lives in one place.
package struct PaymentMethodLogoView: UIViewRepresentable {

    // MARK: - Properties

    private let url: URL
    private let theme: CheckoutTheme
    private let size: CGSize

    // MARK: - Initializers

    package init(url: URL, theme: CheckoutTheme, size: CGSize) {
        self.url = url
        self.theme = theme
        self.size = size
    }

    // MARK: - UIViewRepresentable

    package func makeUIView(context: Context) -> PaymentLogoView {
        let logoView = PaymentLogoView(size: size)
        updateUIView(logoView, context: context)
        return logoView
    }

    package func updateUIView(_ logoView: PaymentLogoView, context: Context) {
        logoView.shadowColor = theme.colors.supportShadow
        logoView.placeholderColor = theme.colors.disabled
        logoView.load(url: url)
    }

    package func sizeThatFits(_ proposal: ProposedViewSize, uiView: PaymentLogoView, context: Context) -> CGSize? {
        size
    }
}
