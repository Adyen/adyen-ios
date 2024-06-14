//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen
import UIKit

/// Contains the styling customization options for Delegated Authentication Screens(Registration & Approval)
public struct DelegatedAuthenticationComponentStyle {
    
    /// The background color of the screens
    public var backgroundColor = UIColor.Adyen.componentBackground

    /// The Image style of the biometric logo
    public var imageStyle: ImageStyle = .init(borderColor: nil,
                                              borderWidth: 0.0,
                                              cornerRadius: 0.0,
                                              clipsToBounds: true,
                                              contentMode: .scaleAspectFit)
    /// The text style of the header.
    public var headerTextStyle = TextStyle(font: .preferredFont(forTextStyle: .title1),
                                           color: UIColor.Adyen.componentLabel,
                                           textAlignment: .center)
    
    /// The text style of the description.
    public var descriptionTextStyle = TextStyle(font: .preferredFont(forTextStyle: .body),
                                                color: UIColor.Adyen.componentSecondaryLabel,
                                                textAlignment: .center)
    
    public var amountTextStyle = TextStyle(font: .preferredFont(forTextStyle: .headline),
                                           color: UIColor.Adyen.componentLabel,
                                           textAlignment: .center)
    
    public var cardImageStyle: ImageStyle = .init(borderColor: nil,
                                                  borderWidth: 0.0,
                                                  cornerRadius: 0.0,
                                                  clipsToBounds: true,
                                                  contentMode: .scaleAspectFit)
    
    public var cardNumberTextStyle = TextStyle(font: .preferredFont(forTextStyle: .title2),
                                               color: UIColor.Adyen.componentLabel,
                                               textAlignment: .center)
    
    public var infoImageStyle: ImageStyle = .init(borderColor: nil,
                                                  borderWidth: 0.0,
                                                  cornerRadius: 0.0,
                                                  clipsToBounds: true,
                                                  contentMode: .scaleAspectFit)
    
    public var additionalInformationTextStyle = TextStyle(font: .preferredFont(forTextStyle: .caption1),
                                                          color: UIColor.Adyen.componentLabel,
                                                          textAlignment: .center)

    /// The style of the timer progress view.
    public var progressViewStyle = ProgressViewStyle(
        progressTintColor: UIColor.Adyen.defaultBlue,
        trackTintColor: UIColor.Adyen.lightGray
    )
    
    /// The text style of the text under the progress view to indicate the time remaining.
    public var remainingTimeTextStyle = TextStyle(font: .preferredFont(forTextStyle: .caption1),
                                                  color: UIColor.Adyen.componentSecondaryLabel,
                                                  textAlignment: .center)
    
    /// The text style of the option to delete the credentials in the approval screen.
    public var textViewStyle = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                         color: UIColor.Adyen.componentLabel,
                                         textAlignment: .center)
    
    /// The primary button style.
    public var primaryButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline),
                         color: .white),
        cornerRadius: 8,
        background: UIColor.Adyen.defaultBlue
    )

    /// The secondary button style.
    public var secondaryButton = ButtonStyle(
        title: TextStyle(font: .preferredFont(forTextStyle: .headline),
                         color: UIColor.Adyen.defaultBlue),
        cornerRadius: 8,
        background: .clear
    )
    
    /// Creates a component style with the default styling
    public init() {
        imageStyle.tintColor = .systemGray
    }
}
