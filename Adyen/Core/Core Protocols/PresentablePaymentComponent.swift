//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Describes any entity that is UI localizable.
package protocol Localizable {
    
    /// Indicates the localization parameters, leave it nil to use the default parameters.
    var localizationParameters: LocalizationParameters? { get set }
}

/// Represents any object than can handle a cancel event.
package protocol Cancellable: AnyObject {
    
    /// Called when the user cancels the component.
    func didCancel()
}
