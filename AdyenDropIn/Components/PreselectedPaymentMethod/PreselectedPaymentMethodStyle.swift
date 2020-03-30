//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Style to describe a component's UI.
internal struct PreselectedPaymentMethodStyle {
    
    /// Style for a submit payment button.
    public let submitButton: ButtonStyle = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 17.0, weight: .semibold),
                                                                        color: .white,
                                                                        textAlignment: .center),
                                                       cornerRadius: 8.0)
    
    /// Style for a button to open all available payment methods.
    public let openAllButton: ButtonStyle = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 17.0, weight: .regular),
                                                                         color: .systemBlue,
                                                                         textAlignment: .center),
                                                        cornerRadius: 0.0,
                                                        background: .clear)
    
    /// Style for a  stored payment component's visialisation.
    public let item: ListItemStyle
    
}
