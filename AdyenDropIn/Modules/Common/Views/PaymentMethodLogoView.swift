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

internal struct PaymentLogoView: View {

    private enum Shadow {
        static let nearOpacity: Double = 0.02
        static let nearRadius: CGFloat = 2
        static let nearOffset: CGFloat = 2

        static let farOpacity: Double = 0.04
        static let farRadius: CGFloat = 4
        static let farOffset: CGFloat = 4
    }

    // MARK: - Properties

    internal let url: URL
    internal let theme: CheckoutTheme
    internal let size: CGSize

    // MARK: - Body

    internal var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: AdyenUIConstants.imageCornerRadius))
        } placeholder: {
            RoundedRectangle(cornerRadius: AdyenUIConstants.imageCornerRadius)
                .fill(Color(uiColor: theme.colors.disabled))
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: shadowColor.opacity(Shadow.nearOpacity), radius: Shadow.nearRadius, y: Shadow.nearOffset)
        .shadow(color: shadowColor.opacity(Shadow.farOpacity), radius: Shadow.farRadius, y: Shadow.farOffset)
    }

    private var shadowColor: Color {
        Color(uiColor: theme.colors.supportShadow)
    }
}
