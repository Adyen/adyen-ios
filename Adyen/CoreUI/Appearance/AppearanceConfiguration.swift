//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object used to customize the appearance of the UI components provided by this SDK.
/// Note that `AppearanceConfiguration` is only used when the `CheckoutViewController` is first initialized. Changes to this object after it has been created are ignored.
public final class AppearanceConfiguration {
    
    // MARK: - Initializing
    
    /// Initializes the appearance configuration.
    public init() {
        
    }
    
    // MARK: - Configuring the Status Bar
    
    /// The preferred status bar style.
    public var preferredStatusBarStyle = UIStatusBarStyle.default
    
    // MARK: - Configuring the Navigation Bar
    
    /// The attributes used for the navigation bar's title.
    public var navigationBarTitleTextAttributes: [String: Any]?
    
    /// The navigation bar's tint color.
    public var navigationBarTintColor: UIColor?
    
    /// The navigation bar's background color.
    public var navigationBarBackgroundColor: UIColor?
    
    /// A Boolean value indicating whether the navigation bar is translucent.
    public var isNavigationBarTranslucent = true
    
    /// The image of the cancel button in the navigation bar, or `nil` if a title should be used instead.
    public var navigationBarCancelButtonImage: UIImage?
    
    // MARK: - Configuring the Checkout Button
    
    /// The attributes used for the checkout button's title.
    public var checkoutButtonTitleTextAttributes: [String: Any]?
    
    /// The insets from the edges of the checkout button to the title.
    public var checkoutButtonTitleEdgeInsets: UIEdgeInsets?
    
    /// The corner radius of the checkout button.
    public var checkoutButtonCornerRadius: CGFloat = 0.0
    
    // MARK: - Configuring Other Display Properties
    
    /// The tint color for most buttons and actionable elements.
    public var tintColor: UIColor?
    
    // MARK: - Getting the Default Appearance Configuration
    
    /// Returns an instance of the default appearance configuration.
    public static var `default`: AppearanceConfiguration = {
        let appearanceConfiguration = AppearanceConfiguration()
        appearanceConfiguration.navigationBarTitleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: UIColor.checkoutDarkGray
        ]
        appearanceConfiguration.navigationBarTintColor = UIColor.checkoutDarkGray
        appearanceConfiguration.navigationBarBackgroundColor = UIColor.white
        appearanceConfiguration.isNavigationBarTranslucent = false
        appearanceConfiguration.navigationBarCancelButtonImage = UIImage.bundleImage("close")
        
        appearanceConfiguration.checkoutButtonTitleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: UIColor.white
        ]
        appearanceConfiguration.checkoutButtonTitleEdgeInsets = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
        appearanceConfiguration.checkoutButtonCornerRadius = 4.0
        
        appearanceConfiguration.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7490196078, blue: 0.3254901961, alpha: 1)
        
        return appearanceConfiguration
    }()
    
}

extension AppearanceConfiguration: NSCopying {
    
    /// :nodoc:
    public func copy(with zone: NSZone? = nil) -> Any {
        let appearanceConfiguration = AppearanceConfiguration()
        appearanceConfiguration.preferredStatusBarStyle = preferredStatusBarStyle
        appearanceConfiguration.navigationBarTitleTextAttributes = navigationBarTitleTextAttributes
        appearanceConfiguration.navigationBarTintColor = navigationBarTintColor
        appearanceConfiguration.navigationBarBackgroundColor = navigationBarBackgroundColor
        appearanceConfiguration.isNavigationBarTranslucent = isNavigationBarTranslucent
        appearanceConfiguration.navigationBarCancelButtonImage = navigationBarCancelButtonImage
        appearanceConfiguration.checkoutButtonTitleTextAttributes = checkoutButtonTitleTextAttributes
        appearanceConfiguration.checkoutButtonTitleEdgeInsets = checkoutButtonTitleEdgeInsets
        appearanceConfiguration.checkoutButtonCornerRadius = checkoutButtonCornerRadius
        appearanceConfiguration.tintColor = tintColor
        
        return appearanceConfiguration
    }
    
    /// Creates and returns a copied version of the receiver.
    internal var copied: AppearanceConfiguration {
        return copy() as! AppearanceConfiguration // swiftlint:disable:this force_cast
    }
    
}

internal extension AppearanceConfiguration {
    
    internal func cancelButtonItem(target: Any, selector: Selector) -> UIBarButtonItem {
        var cancelButtonItem: UIBarButtonItem!
        if let cancelButtonImage = navigationBarCancelButtonImage {
            cancelButtonItem = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: target, action: selector)
            cancelButtonItem.accessibilityLabel = ADYLocalizedString("cancelButton")
        } else {
            cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: selector)
        }
        
        return cancelButtonItem
    }
    
}
