//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object used to customize the appearance of the UI components provided by this SDK.
/// Note that `AppearanceConfiguration` is only used when the `CheckoutViewController` is first initialized. Changes to this object after it has been created are ignored.
public struct AppearanceConfiguration {
    
    // MARK: - Initializing
    
    /// Initializes the appearance configuration.
    public init() {
        
    }
    
    // MARK: - Configuring the Status Bar
    
    /// The preferred status bar style.
    public var preferredStatusBarStyle = UIStatusBarStyle.default
    
    // MARK: - Configuring the Navigation Bar Title Text Appearance
    
    /// The attributes used for the navigation bar's title.
    public var navigationBarTitleTextAttributes: [NSAttributedStringKey: Any]?
    
    /// The attributes used for the navigation bar's large title. Only has an effect on iOS 11 and higher.
    public var navigationBarLargeTitleTextAttributes: [NSAttributedStringKey: Any]?
    
    /// Display modes for the large title in a navigation bar.
    public enum NavigationBarLargeTitleDisplayMode {
        
        /// Always display a large title.
        case always
        
        /// Only display a large title for the root view controller.
        case root
        
        /// Never display a large title.
        case never
    }
    
    /// The display mode for the large title in the navigation bar. Only has an effect on iOS 11 and higher.
    public var navigationBarLargeTitleDisplayMode = NavigationBarLargeTitleDisplayMode.root
    
    // MARK: - Configuring the Navigation Bar Appearance
    
    /// The navigation bar's tint color.
    public var navigationBarTintColor: UIColor?
    
    /// The navigation bar's background color.
    public var navigationBarBackgroundColor: UIColor?
    
    /// A Boolean value indicating whether the navigation bar is translucent.
    public var isNavigationBarTranslucent = true
    
    /// The image of the cancel button in the navigation bar, or `nil` if a title should be used instead.
    public var navigationBarCancelButtonImage: UIImage?
    
    // MARK: - Configuring the Checkout Button
    
    /// The class to use for the checkout button.
    /// The button's title and enabled/disabled state will be managed by Adyen SDK.
    /// When no type is specified, a default button is used.
    public var checkoutButtonType: UIButton.Type = UIButton.self
    
    // MARK: - Configuring Safari View Controller
    
    /// The color to tint the background of the Safari View Controller navigation bar and toolbar. Only has an effect on iOS 11 and higher.
    public var safariBarTintColor: UIColor?
    
    /// The color to tint the the control buttons on Safari View Controller the navigation bar and the toolbar. Only has an effect on iOS 11 and higher.
    public var safariControlTintColor: UIColor?
    
    // MARK: - Configuring General Display Properties
    
    /// The tint color for most buttons and actionable elements.
    public var tintColor: UIColor?
    
    /// The background color of all view controllers.
    public var backgroundColor: UIColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
    
    // MARK: - Getting the Default Appearance Configuration
    
    /// Returns an instance of the default appearance configuration.
    public static let `default`: AppearanceConfiguration = {
        var appearanceConfiguration = AppearanceConfiguration()
        appearanceConfiguration.navigationBarTitleTextAttributes = [
            .foregroundColor: UIColor.checkoutDarkGray
        ]
        appearanceConfiguration.navigationBarTintColor = UIColor.checkoutDarkGray
        appearanceConfiguration.navigationBarBackgroundColor = UIColor.white
        appearanceConfiguration.navigationBarCancelButtonImage = UIImage.bundleImage("close")
        
        appearanceConfiguration.checkoutButtonType = CheckoutButton.self
        appearanceConfiguration.internalCheckoutButtonTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18.0),
            .foregroundColor: UIColor.white
        ]
        appearanceConfiguration.internalCheckoutButtonTitleEdgeInsets = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 16.0, right: 0.0)
        appearanceConfiguration.internalCheckoutButtonCornerRadius = 4.0
        
        appearanceConfiguration.tintColor = #colorLiteral(red: 0.03921568627, green: 0.7490196078, blue: 0.3254901961, alpha: 1)
        
        return appearanceConfiguration
    }()
    
    // MARK: - Internal
    
    internal var internalCheckoutButtonTitleTextAttributes: [NSAttributedStringKey: Any]? // swiftlint:disable:this identifier_name
    
    internal var internalCheckoutButtonTitleEdgeInsets: UIEdgeInsets?
    
    internal var internalCheckoutButtonCornerRadius: CGFloat = 0.0
    
}

public extension AppearanceConfiguration {
    
    // MARK: - Deprecated
    
    /// The attributes used for the checkout button's title. Only used when `checkoutButtonType` is the default.
    @available(*, deprecated, message: "Provide a custom button via checkoutButtonType instead.")
    public var checkoutButtonTitleTextAttributes: [NSAttributedStringKey: Any]? {
        get {
            return internalCheckoutButtonTitleTextAttributes
        }
        
        set {
            internalCheckoutButtonTitleTextAttributes = newValue
        }
    }
    
    /// The insets from the edges of the checkout button to the title. Only used when `checkoutButtonType` the default.
    @available(*, deprecated, message: "Provide a custom button via checkoutButtonType instead.")
    public var checkoutButtonTitleEdgeInsets: UIEdgeInsets? {
        get {
            return internalCheckoutButtonTitleEdgeInsets
        }
        
        set {
            internalCheckoutButtonTitleEdgeInsets = newValue
        }
    }
    
    /// The corner radius of the checkout button. Only used when `checkoutButtonType` the default.
    @available(*, deprecated, message: "Provide a custom button via checkoutButtonType instead.")
    public var checkoutButtonCornerRadius: CGFloat {
        get {
            return internalCheckoutButtonCornerRadius
        }
        
        set {
            internalCheckoutButtonCornerRadius = newValue
        }
    }
    
}

// MARK: - Helpers

internal extension AppearanceConfiguration {
    
    /// The globally shared appearance configuration.
    internal static var shared = AppearanceConfiguration.default
    
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
