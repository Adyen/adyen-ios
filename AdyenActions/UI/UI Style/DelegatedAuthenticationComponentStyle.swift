//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

/// Contains the styling customization options for Delegated Authentication Screens(Registration & Approval)
package struct DelegatedAuthenticationComponentStyle {
    
    /// The background color of the approval and the register screen
    package var backgroundColor = UIColor.Adyen.componentBackground

    /// The Image style of the approval and the register screen
    package var imageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )
    /// The text style of the header of the approval and the register screen
    package var headerTextStyle = TextStyle(
        font: .systemFont(ofSize: 24, weight: .bold),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .center
    )
    
    /// The text style of the description of the approval and the register screen
    package var descriptionTextStyle = TextStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .center
    )
    
    /// The text style of the amount of the approval
    package var amountTextStyle = TextStyle(
        font: .systemFont(ofSize: 32),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .center
    )
    
    /// The card type image style of the approval and the register screen
    package var cardImageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )
    
    /// The card number style of the approval and the register screen
    package var cardNumberTextStyle = TextStyle(
        font: .systemFont(ofSize: 24, weight: .bold),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .center
    )
    
    /// The image style of the register screen for the additional info section
    package var infoImageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )
    
    /// The text style of the register screen for the additional info section
    package var additionalInformationTextStyle = TextStyle(
        font: .preferredFont(forTextStyle: .caption1),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .center
    )
    
    /// The background color of the approval and the register screen
    package var errorBackgroundColor = UIColor.Adyen.componentBackground

    /// The image style for the error screen
    package var errorImageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )
    
    /// The error title style for the error screen
    package var errorTitleStyle = TextStyle(
        font: .preferredFont(forTextStyle: .title1),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .center
    )
    
    /// The error description style for the error screen
    package var errorDescription = TextStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .center
    )
    
    /// The title style for the troubleshooting message
    package var troubleshootingTitleStyle = TextStyle(
        font: .preferredFont(forTextStyle: .subheadline),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .center
    )
    
    /// The description style for the troubleshooting message
    package var troubleshootingDescriptionStyle = TextStyle(
        font: .preferredFont(forTextStyle: .caption1),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .center
    )
    
    /// The button style for the troubleshooting message
    package var troubleshootingButtonStyle = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: UIColor.Adyen.defaultBlue
        ),
        cornerRadius: 8,
        background: .clear
    )

    /// The primary button style for the register & approve screens.
    package var primaryButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: .white
        ),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )

    /// The secondary button style for the register & approve screens.
    package var secondaryButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: UIColor.Adyen.defaultBlue
        ),
        cornerRadius: 8,
        background: .clear
    )
    
    /// The primary button style for the error screen.
    package var errorButton = ButtonStyle(
        title: TextStyle(
            font: .preferredFont(forTextStyle: .headline),
            color: .white
        ),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )

    /// Creates a component style with the default styling
    package init() {
        imageStyle.tintColor = .systemGray
    }
}
