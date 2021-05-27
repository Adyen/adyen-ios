//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Describes any entity that is UI localizable.
public protocol Localizable {
    
    /// Indicates the localization parameters, leave it nil to use the default parameters.
    var localizationParameters: LocalizationParameters? { get set }
}

/// :nodoc:
/// Represents any object than can handle a cancel event.
public protocol Cancellable: AnyObject {
    
    /// :nodoc:
    /// Called when the user cancels the component.
    func didCancel()
}

/// A component that provides a view controller for the shopper to fill payment details.
public protocol PresentableComponent: Component {
    
    /// Indicates whether `viewController` expected to be presented modally,
    /// hence it can not handle it's own presentation and dismissal.
    var requiresModalPresentation: Bool { get }
    
    /// Returns a view controller that presents the payment details for the shopper to fill.
    var viewController: UIViewController { get }
}

/// :nodoc:
public extension PresentableComponent {
    
    /// :nodoc:
    var requiresModalPresentation: Bool { false }
    
}

/// :nodoc:
public protocol TrackableComponent: Component, PaymentMethodAware, ViewControllerDelegate {}

/// :nodoc:
extension TrackableComponent {
    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
    }

    /// :nodoc:
    public func viewDidAppear(viewController: UIViewController) { /* Empty Implementation */ }
}
