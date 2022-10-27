//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
extension UIProgressView {
    
    /// :nodoc:
    public convenience init(style: ProgressViewStyle) {
        self.init()
        
        backgroundColor = style.backgroundColor
        progressTintColor = style.progressTintColor
        trackTintColor = style.trackTintColor
    }
}
