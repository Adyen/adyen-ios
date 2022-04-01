//
// Copyright (c) 2022 Adyen N.V.
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

/// :nodoc:
/// Represents navigation bar on top of presentable components.
public protocol AnyNavigationBar: UIView {
    
    var onCancelHandler: (() -> Void)? { get set }
    
}

/// :nodoc:
public enum NavigationBarType {
    case regular
    case custom(AnyNavigationBar)
}

/// A component that provides a view controller for the shopper to fill payment details.
public protocol PresentableComponent: Component {
    
    /// Indicates whether `viewController` expected to be presented modally,
    /// hence it can not handle its own presentation and dismissal.
    var requiresModalPresentation: Bool { get }
    
    /// Returns a view controller that presents the payment details for the shopper to fill.
    var viewController: UIViewController { get }
    
    /// Indicates whether Component implements a custom Navigation bar.
    var navBarType: NavigationBarType { get }
}

/// :nodoc:
public extension PresentableComponent {
    
    /// :nodoc:
    var requiresModalPresentation: Bool { false }
    
    /// :nodoc:
    var navBarType: NavigationBarType { .regular }
    
}

/// :nodoc:
public protocol TrackableComponent: Component {

    func sendTelemetryEvent()
}

/// :nodoc:
extension TrackableComponent where Self: PaymentMethodAware {

    public func sendTelemetryEvent() {
        let flavor: TelemetryFlavor = _isDropIn ? .dropInComponent : .components(type: paymentMethod.type)
        adyenContext.analyticsProvider.trackTelemetryEvent(flavor: flavor)
    }
}
