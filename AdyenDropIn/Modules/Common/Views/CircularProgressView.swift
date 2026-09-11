//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenUI
import Foundation
import SwiftUI

internal struct CircularProgressView: View {

    private enum Constants {
        static let arcLength = 0.25
        static let rotationDuration = 0.8
    }

    // MARK: - Properties

    internal let theme: CheckoutTheme
    internal let size: CGFloat
    internal let lineWidth: CGFloat
    @State private var isRotating = false

    // MARK: - Body

    internal var body: some View {
        ZStack {
            Circle()
                .stroke(Color(uiColor: theme.colors.textOnDisabled).opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: Constants.arcLength)
                .stroke(
                    Color(uiColor: theme.colors.text),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(isRotating ? 360 : 0))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
        .onAppear {
            withAnimation(.linear(duration: Constants.rotationDuration).repeatForever(autoreverses: false)) {
                isRotating = true
            }
        }
    }
}
