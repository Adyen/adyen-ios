//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// Contains properties that allow for customization of the UI's appearance.
public struct Appearance {
    /// :nodoc:
    public init() {}
    
    /// The preferred status bar style for view controllers presented by the SDK.
    public var preferredStatusBarStyle: UIStatusBarStyle?
    
    /// The color of an activity indicator.
    public var activityIndicatorColor: UIColor?
    
    /// The tint color of the controls.
    public var tintColor: UIColor?
    
    /// The background color of all views.
    public var backgroundColor = UIColor.white
    
    /// Navigation bar attributes.
    public var navigationBarAttributes = NavigationBarAttributes()
    
    /// Safari View Controller attributes.
    public var safariViewControllerAttributes = SafariViewControllerAttributes()
    
    /// Checkout button attributes.
    public var checkoutButtonAttributes = CheckoutButtonAttributes()
    
    /// List attributes.
    public var listAttributes = ListAttributes()
    
    /// Form attributes.
    public var formAttributes = FormAttributes()
    
    /// Text attributes that are applied to all regular text labels.
    public var textAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.black,
        .font: UIFont.systemFont(ofSize: 17)
    ]
}

// MARK: - Appearance.NavigationBarAttributes

extension Appearance {
    /// Contains properties for customizing the appearance of navigation bars.
    public struct NavigationBarAttributes {
        /// :nodoc:
        public init() {}
        
        /// The attributes used for the navigation bar's title.
        public var titleAttributes: [NSAttributedString.Key: Any]?
        
        /// The navigation bar's tint color.
        public var tintColor: UIColor?
        
        /// The navigation bar's background color.
        public var backgroundColor: UIColor? = UIColor.white
        
        /// The image of the cancel button in the navigation bar, or `nil` if a title should be used instead.
        public var cancelButtonImage: UIImage?
        
        /// A boolean value indicating whether the navigation bar is translucent.
        public var isNavigationBarTranslucent = true
    }
}

// MARK: - Appearance.SafariViewControllerAttributes

extension Appearance {
    /// Contains variables for customizing the appearance of an SFSafariViewController.
    public struct SafariViewControllerAttributes {
        /// :nodoc:
        public init() {}
        
        /// The color to tint the background of the navigation bar and toolbar in SFSafariViewController.
        public var barTintColor: UIColor?
        
        /// The color to tint the control buttons on the navigation bar and toolbar in SFSafariViewController.
        public var controlTintColor: UIColor?
    }
}

// MARK: - Appearance.CheckoutButtonAttributes

extension Appearance {
    /// Contains variables for customizing the appearance of the checkout button.
    public struct CheckoutButtonAttributes {
        /// :nodoc:
        public init() {}
        
        /// The type of the button to use. Use this property to pass in a custom UIButton subclass to use as a checkout button.
        /// When supplying a custom button type, none of the other customization properties are used.
        public var type: UIButton.Type = CheckoutButton.self
        
        /// The title of the checkout button.
        public var title: String?
        
        /// The attributes used for the checkout button's title.
        public var titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        
        /// The corner radius of the checkout button.
        public var cornerRadius: CGFloat = 8.0
        
        /// The background color of the checkout button, or `nil` if the `tintColor` should be used.
        public var backgroundColor: UIColor?
        
        /// Returns the title for the checkout button.
        ///
        /// - Parameters:
        ///   - amount: The amount of the current payment.
        ///   - currencyCode: The currency code of the amount of the current payment.
        /// - Returns: The checkout button title.
        @available(*, deprecated, renamed: "title(for:)")
        public func title(forAmount amount: Int?, currencyCode: String?) -> String {
            guard let amount = amount, let currencyCode = currencyCode else {
                return title(for: nil)
            }
            
            return title(for: PaymentSession.Payment.Amount(value: amount, currencyCode: currencyCode))
        }
        
        /// Returns the title for the checkout button.
        ///
        /// - Parameters:
        ///   - amount: The amount of the current payment.
        /// - Returns: The checkout button title.
        public func title(for amount: PaymentSession.Payment.Amount?) -> String {
            let payActionTitle: String
            
            if let buttonTitle = title {
                payActionTitle = buttonTitle
            } else if let amount = amount {
                let formattedAmount = AmountFormatter.formatted(amount: amount.value, currencyCode: amount.currencyCode) ?? ""
                payActionTitle = ADYLocalizedString("payButton.formatted", formattedAmount)
            } else {
                payActionTitle = ADYLocalizedString("payButton")
            }
            
            return payActionTitle
        }
    }
}

// MARK: - Appearance.ListAttributes

extension Appearance {
    /// Contains variables for customizing the appearance of lists.
    public struct ListAttributes {
        /// :nodoc:
        public init() {}
        
        /// The color of the disclosure indicator.
        public var disclosureIndicatorColor: UIColor?
        
        /// The color of a list item's background when it's selected.
        public var selectionColor: UIColor?
        
        /// The color of an activity indicator displayed in a list.
        public var activityIndicatorColor: UIColor?
        
        /// The attributes used for a list's section titles.
        public var sectionTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)
        ]
        
        /// The attributes used for a list's cell subtitles.
        public var cellSubtitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(red: 0.42, green: 0.42, blue: 0.44, alpha: 1),
            .font: UIFont.systemFont(ofSize: 13)
        ]
    }
}

// MARK: - Appearance.FormAttributes

extension Appearance {
    /// Contains variables for customizing the appearance of forms.
    public struct FormAttributes {
        /// :nodoc:
        public init() {}
        
        /// The attributes used for a form's title.
        public var titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        /// The attributes used for a form's field titles.
        public var fieldTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.darkGray,
            .font: UIFont.systemFont(ofSize: 13, weight: .regular)
        ]
        
        /// The attributes used for a form's footer title.
        public var footerTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 13)
        ]
        
        /// The attributes used for a form's section titles.
        public var sectionTitleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        /// The color of a field's text when it's invalid.
        public var invalidTextColor = UIColor.red
        
        /// The attributes used for a field's placeholder.
        public var placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 17)
        ]
        
        /// The color of the separator inbetween a form's fields.
        public var separatorColor: UIColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
        
        /// The color of the switch's thumb in a form.
        public var switchThumbColor: UIColor?
        
        /// The tint color of a switch in a form.
        public var switchTintColor: UIColor?
    }
}

internal extension Appearance {
    /// The globally shared appearance configuration.
    static var shared = Appearance()
}

internal extension Appearance {
    func payButton() -> UIButton {
        let payButton = checkoutButtonAttributes.type.init()
        payButton.tintColor = tintColor
        payButton.accessibilityIdentifier = "pay-button"
        return payButton
    }
    
    func cancelButtonItem(target: Any, selector: Selector) -> UIBarButtonItem {
        var cancelButtonItem: UIBarButtonItem
        
        if let cancelButtonImage = navigationBarAttributes.cancelButtonImage {
            cancelButtonItem = UIBarButtonItem(image: cancelButtonImage, style: .plain, target: target, action: selector)
            cancelButtonItem.accessibilityLabel = ADYLocalizedString("cancelButton")
        } else {
            cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: selector)
        }
        
        return cancelButtonItem
    }
}
