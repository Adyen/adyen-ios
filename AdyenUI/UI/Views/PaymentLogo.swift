//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

/// SwiftUI wrapper around the shared `AdyenUI.PaymentLogoView` so all logo styling lives in one place.
package struct PaymentLogo: View {

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

    // MARK: - Body

    package var body: some View {
        LogoViewRepresentable(url: url, theme: theme, size: size)
            .frame(width: size.width, height: size.height)
    }
}

private struct LogoViewRepresentable: UIViewRepresentable {

    internal let url: URL
    internal let theme: CheckoutTheme
    internal let size: CGSize

    internal func makeUIView(context: Context) -> PaymentLogoView {
        let logoView = PaymentLogoView(size: size)
        logoView.shadowColor = theme.colors.supportShadow
        logoView.placeholderColor = theme.colors.disabled
        logoView.load(url: url)
        return logoView
    }

    internal func updateUIView(_ logoView: PaymentLogoView, context: Context) {
        logoView.shadowColor = theme.colors.supportShadow
        logoView.placeholderColor = theme.colors.disabled
        logoView.load(url: url)
    }
}
