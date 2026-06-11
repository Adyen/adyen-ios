//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any form-based component.
package struct FormComponentStyle: TintableStyle {

    package var backgroundColor = UIColor.Adyen.componentBackground

    /// The section header style.
    package var sectionHeader = TextStyle(
        font: .preferredFont(forTextStyle: .headline),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    ) {
        didSet {
            addressStyle.title = sectionHeader
        }
    }
    
    /// The text field style.
    package var textField = FormTextItemStyle() {
        didSet {
            addressStyle.textField = textField
        }
    }
    
    /// The toggle style.
    package var toggle = FormToggleItemStyle()

    /// The helper message style.
    package var hintLabel = TextStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )

    /// The foot note text style.
    package var footnoteLabel = TextStyle(
        font: .preferredFont(forTextStyle: .footnote),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .center
    )

    /// The link text style.
    package var linkTextLabel = TextStyle(
        font: .preferredFont(forTextStyle: .footnote),
        color: UIColor.Adyen.defaultBlue,
        textAlignment: .center
    )
    
    /// The main button style.
    package var mainButtonItem: FormButtonItemStyle = .main(
        font: .preferredFont(forTextStyle: .headline),
        textColor: .white,
        mainColor: UIColor.Adyen.defaultBlue
    )
    
    /// The secondary button style.
    package var secondaryButtonItem: FormButtonItemStyle = .secondary(
        font: .preferredFont(forTextStyle: .body),
        textColor: UIColor.Adyen.defaultBlue
    )

    /// The  segmented control  style.
    package var segmentedControlStyle: SegmentedControlStyle = .init(
        textStyle: TextStyle(
            font: .preferredFont(forTextStyle: .subheadline),
            color: UIColor.Adyen.componentBackground
        )
    )

    /// The address style generated based on other field's value.
    package var addressStyle: AddressStyle

    /// The error message indicator style.
    package var errorStyle = FormErrorItemStyle()

    /// Set tint color of form.
    /// When set, updates tint colors for all underlying styles.
    /// If value is nil, the default color would be used.
    package var tintColor: UIColor? {
        didSet {
            setTintColor(tintColor)
        }
    }
    
    /// The color for separator element.
    /// When set, updates separator colors for all underlying styles unless the value were set previously.
    /// If value is nil, the default color would be used.
    package var separatorColor: UIColor? {
        didSet {
            textField.separatorColor = textField.separatorColor ?? separatorColor
            toggle.separatorColor = toggle.separatorColor ?? separatorColor
        }
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter textField: The text field style.
    /// - Parameter toggle: The toggle style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    /// - Parameter helper: The helper message style.
    /// - Parameter sectionHeader: The section header style.
    package init(
        textField: FormTextItemStyle,
        toggle: FormToggleItemStyle,
        mainButton: FormButtonItemStyle,
        secondaryButton: FormButtonItemStyle,
        helper: TextStyle,
        sectionHeader: TextStyle
    ) {
        self.textField = textField
        self.toggle = toggle
        self.mainButtonItem = mainButton
        self.secondaryButtonItem = secondaryButton
        self.hintLabel = helper
        self.sectionHeader = sectionHeader
        self.addressStyle = .init(title: sectionHeader, textField: textField)
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter textField: The text field style.
    /// - Parameter toggle: The toggle style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    package init(
        textField: FormTextItemStyle,
        toggle: FormToggleItemStyle,
        mainButton: ButtonStyle,
        secondaryButton: ButtonStyle
    ) {
        self.textField = textField
        self.toggle = toggle
        self.mainButtonItem = FormButtonItemStyle(button: mainButton)
        self.secondaryButtonItem = FormButtonItemStyle(button: secondaryButton)
        self.addressStyle = .init(title: sectionHeader, textField: textField)
    }
    
    /// Initializes the form style with the default style and custom tint for all elements.
    /// - Parameter tintColor: The color for tinting buttons. textfields, icons and switches.
    package init(tintColor: UIColor) {
        self.addressStyle = .init(title: sectionHeader, textField: textField)
        setTintColor(tintColor)
    }
    
    /// Initializes the form style with the default style.
    package init() {
        self.addressStyle = .init(title: sectionHeader, textField: textField)
    }

    private mutating func setTintColor(_ value: UIColor?) {
        guard let tintColor = value else { return }
        mainButtonItem.button.backgroundColor = tintColor
        secondaryButtonItem.button.title.color = tintColor

        textField = FormTextItemStyle(tintColor: tintColor)
        toggle.tintColor = tintColor
    }
    
}
