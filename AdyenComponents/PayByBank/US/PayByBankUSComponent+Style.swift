//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

extension PayByBankUSComponent {
    
    package struct Style {
        package var title: TextStyle = {
            let titleSize = UIFont.preferredFont(forTextStyle: .title1).pointSize
            return TextStyle(
                font: .systemFont(ofSize: titleSize, weight: .bold),
                color: UIColor.Adyen.componentLabel
            )
        }()
        
        package var subtitle: TextStyle = {
            let subtitleSize: CGFloat = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
            return TextStyle(
                font: .systemFont(ofSize: subtitleSize, weight: .medium),
                color: UIColor.Adyen.componentLabel
            )
        }()
        
        package var message: TextStyle = {
            let messageSize: CGFloat = UIFont.preferredFont(forTextStyle: .subheadline).pointSize
            return TextStyle(
                font: .systemFont(ofSize: messageSize, weight: .regular),
                color: UIColor.Adyen.componentSecondaryLabel
            )
        }()
        
        package var headerImage: ImageStyle = .init(
            borderColor: UIColor.Adyen.componentSeparator,
            borderWidth: 0,
            cornerRadius: 8.0,
            clipsToBounds: true,
            contentMode: .scaleAspectFit
        )
        
        package var submitButton: ButtonStyle = .init(
            title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
            cornerRounding: .fixed(8),
            background: UIColor.Adyen.defaultBlue
        )
        
        package init() {}
    }
}
