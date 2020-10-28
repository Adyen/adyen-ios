//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any views.
public protocol ViewStyle {
    
    /// The background color of the view.
    var backgroundColor: UIColor { get set }
    
}

/// Contains the styling customization options for views with acent color.
public protocol TintableStyle: ViewStyle {
    
    /// The tint color of the view.
    var tintColor: UIColor? { get set }
    
}
