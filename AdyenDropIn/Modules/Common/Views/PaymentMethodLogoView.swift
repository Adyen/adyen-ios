//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import Foundation
import SwiftUI

internal struct PaymentLogoView: View {

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
    }
}
