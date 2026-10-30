//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import SwiftUI

/// SwiftUI wrapper around the shared `AdyenUI.PaymentLogoView` so all logo styling lives in one place.
internal struct PaymentMethodLogoView: UIViewRepresentable {

    // MARK: - Properties

    internal let url: URL
    internal let theme: CheckoutTheme
    internal let size: CGSize

    // MARK: - UIViewRepresentable

    internal func makeUIView(context: Context) -> PaymentLogoView {
        let logoView = PaymentLogoView(size: size)
        updateUIView(logoView, context: context)
        return logoView
    }

    internal func updateUIView(_ logoView: PaymentLogoView, context: Context) {
        logoView.shadowColor = theme.colors.supportShadow
        logoView.placeholderColor = theme.colors.disabled
        logoView.load(url: url)
    }

    internal func sizeThatFits(_ proposal: ProposedViewSize, uiView: PaymentLogoView, context: Context) -> CGSize? {
        size
    }
}
