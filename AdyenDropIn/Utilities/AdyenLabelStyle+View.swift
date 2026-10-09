//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal extension View {

    /// Applies an `AdyenLabelStyle`, including its fixed line height, to the view.
    ///
    /// SwiftUI has no line-height property, so the line height is emulated with `lineSpacing`
    /// plus half the extra height as vertical padding, keeping the text vertically centred.
    /// - Parameters:
    ///   - style: The style to apply.
    ///   - color: An optional override for the style's color.
    func adyenLabelStyle(_ style: AdyenLabelStyle, color: UIColor? = nil) -> some View {
        let extraSpacing = max(0, (style.lineHeight ?? style.font.lineHeight) - style.font.lineHeight)
        return font(Font(style.font))
            .foregroundStyle(Color(uiColor: color ?? style.color))
            .lineSpacing(extraSpacing)
            .padding(.vertical, extraSpacing / 2)
    }
}
