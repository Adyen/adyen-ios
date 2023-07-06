//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AddressLookupSearchViewController {
    
    /// The footer view for the result list to allow switching to manual entry
    class FooterView: UIView {
        
        private let style: Style
        private let selectionHandler: () -> Void
        
        internal required init(
            style: Style = .init(),
            selectionHandler: @escaping () -> Void
        ) {
            self.style = style
            self.selectionHandler = selectionHandler
            
            super.init(frame: .zero)
            
            self.backgroundColor = style.backgroundColor
            
            let label = UILabel()
            label.text = "Select your address" // TODO: Alex - Localization
            label.backgroundColor = .yellow
            label.numberOfLines = 0
            label.adyen.apply(style.title)
            
            let textView = LinkTextView { [weak self] _ in
                self?.selectionHandler()
            }
            textView.update(
                text: "or %#enter manually%#", // TODO: Alex - Localization
                style: style.subtitle
            )
            
            let stackView = UIStackView(arrangedSubviews: [label, textView])
            stackView.axis = .vertical
            addSubview(stackView)
            
            stackView.adyen.anchor(inside: self, with: .init(top: 16, left: 16, bottom: -16, right: -16))
        }
        
        @available(*, unavailable)
        internal required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        private func switchToManualEntry() {
            selectionHandler()
        }
    }
}

extension AddressLookupSearchViewController.FooterView {
    
    struct Style: ViewStyle {
        
        internal var title: TextStyle
        internal var subtitle: TextStyle
        internal var backgroundColor: UIColor
        
        internal init(
            title: TextStyle = .init(
                font: .preferredFont(forTextStyle: .subheadline),
                color: .Adyen.componentSecondaryLabel
            ),
            subtitle: TextStyle = .init(
                font: .preferredFont(forTextStyle: .subheadline),
                color: .Adyen.componentSecondaryLabel
            ),
            backgroundColor: UIColor = .clear
        ) {
            self.title = title
            self.subtitle = subtitle
            self.backgroundColor = backgroundColor
        }
    }
}
