//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen
import UIKit

/// Contains the styling customization options for Delegated Authentication Screens.
public struct DelegatedAuthenticationComponentStyle {
    /// The background color of the view
    public var backgroundColor = UIColor.Adyen.componentBackground

    public var imageStyle: ImageStyle = .init(borderColor: nil,
                                              borderWidth: 0.0,
                                              cornerRadius: 0.0,
                                              clipsToBounds: true,
                                              contentMode: .scaleToFill)
    
    public var headerTextStyle = TextStyle(font: .preferredFont(forTextStyle: .title1),
                                           color: UIColor.Adyen.componentLabel,
                                           textAlignment: .natural)
    
    public var descriptionTextStyle = TextStyle(font: .preferredFont(forTextStyle: .body),
                                                color: UIColor.Adyen.componentSecondaryLabel,
                                                textAlignment: .natural)
    
    public var progressViewStyle = ProgressViewStyle(progressTintColor: UIColor.Adyen.componentSecondaryLabel,
                                                     trackTintColor: UIColor.Adyen.componentSecondaryLabel)
    
    public var remainingTimeTextStyle = TextStyle(font: .preferredFont(forTextStyle: .caption1),
                                                  color: UIColor.Adyen.componentSecondaryLabel,
                                                  textAlignment: .natural)
    
    public var footNoteTextStyle = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                             color: UIColor.Adyen.componentLabel,
                                             textAlignment: .natural)
    
    public var textViewStyle = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                         color: UIColor.Adyen.componentLabel,
                                         textAlignment: .natural)
    
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
    
    public init() {
        imageStyle.tintColor = .systemGray
    }
}
