//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

package struct CircularProgressView: View {

    private enum Constants {
        static let arcLength = 0.25
        static let rotationDuration = 0.8
    }

    // MARK: - Properties

    private let arcColor: UIColor
    private let trackColor: UIColor
    private let trackOpacity: Double
    private let size: CGFloat
    private let lineWidth: CGFloat
    @State private var isRotating = false

    // MARK: - Initializers

    package init(theme: CheckoutTheme, size: CGFloat, lineWidth: CGFloat) {
        self.init(
            arcColor: theme.colors.primary,
            trackColor: theme.colors.disabled,
            trackOpacity: 1,
            size: size,
            lineWidth: lineWidth
        )
    }

    package init(
        arcColor: UIColor,
        trackColor: UIColor,
        trackOpacity: Double = 0.15,
        size: CGFloat,
        lineWidth: CGFloat
    ) {
        self.arcColor = arcColor
        self.trackColor = trackColor
        self.trackOpacity = trackOpacity
        self.size = size
        self.lineWidth = lineWidth
    }

    // MARK: - Body

    package var body: some View {
        ZStack {
            Circle()
                .stroke(Color(uiColor: trackColor).opacity(trackOpacity), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: Constants.arcLength)
                .stroke(
                    Color(uiColor: arcColor),
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
