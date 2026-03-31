//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Simple form item that represent a single UILabel element.
@_spi(AdyenInternal)
public class FormLabelItem: FormItem {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public var subitems: [FormItem] = []

    public init(text: String, style: TextStyle, identifier: String? = nil) {
        self.identifier = identifier
        self.style = style
        self.text = text
        self.labelStyle = AdyenLabelStyle()
    }

    package init(
        text: String,
        identifier: String? = nil,
        labelStyle: AdyenLabelStyle
    ) {
        self.identifier = identifier
        self.text = text
        self.labelStyle = labelStyle
        // TODO: TO remove later
        self.style = TextStyle(font: .preferredFont(forTextStyle: .title1), color: .red)
    }

    public var identifier: String?

    /// The style of the label.
    public var style: TextStyle

    /// The text of the label.
    public var text: String

    /// The labelStyle from the adyen theme
    internal var labelStyle: AdyenLabelStyle = .init()

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        FormLabelItemView(item: self, theme: builder.theme)
    }
}

internal final class FormLabelItemView: UILabel, AnyFormItemView {

    private let theme: CheckoutTheme

    internal init(item: FormLabelItem, theme: CheckoutTheme) {
        self.theme = theme
        super.init(frame: .zero)
        configure(with: item)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(with item: FormLabelItem) {
        text = item.text
        numberOfLines = 0
        accessibilityIdentifier = item.identifier

        apply(theme.elements.labels.body)
    }

    // MARK: - AnyFormItemView

    internal var childItemViews: [AnyFormItemView] {
        []
    }
}
