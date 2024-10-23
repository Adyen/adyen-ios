//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

extension PayByBankUSComponent {
    
    public struct Style {
        public var title: TextStyle = {
            let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
            return TextStyle(
                font: .systemFont(ofSize: titleSize, weight: .bold),
                color: UIColor.Adyen.componentLabel
            )
        }()
        
        public var subtitle: TextStyle = {
            let subtitleSize: CGFloat = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
            return TextStyle(
                font: .systemFont(ofSize: subtitleSize, weight: .medium),
                color: UIColor.Adyen.componentLabel
            )
        }()
        
        public var message: TextStyle = {
            let messageSize: CGFloat = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
            return TextStyle(
                font: .systemFont(ofSize: messageSize, weight: .regular),
                color: UIColor.Adyen.componentSecondaryLabel
            )
        }()
        
        public var headerImage: ImageStyle = .init(
            borderColor: UIColor.Adyen.componentSeparator,
            borderWidth: 1.0 / UIScreen.main.nativeScale,
            cornerRadius: 8.0,
            clipsToBounds: true,
            contentMode: .scaleAspectFit
        )
        
        public init() {}
    }
}
