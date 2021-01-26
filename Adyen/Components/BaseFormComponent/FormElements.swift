//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
internal protocol BaseFormElement {

    /// :nodoc:
    associatedtype StyleType: ViewStyle

    /// :nodoc:
    associatedtype ItemType: FormItem

    /// :nodoc:
    var identifier: String { get }

    /// :nodoc:
    var style: StyleType { get }

    /// :nodoc:
    func build(_ itemBuilder: BaseFormBuilder) -> ItemType
}

/// :nodoc:
internal struct FirstNameElement: BaseFormElement {

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal init(identifier: String,
                  style: FormTextItemStyle) {
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    internal func build(_ itemBuilder: BaseFormBuilder) -> FormTextInputItem {
        itemBuilder.build(self)
    }
}

/// :nodoc:
internal struct LastNameElement: BaseFormElement {

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal init(identifier: String,
                  style: FormTextItemStyle) {
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    internal func build(_ itemBuilder: BaseFormBuilder) -> FormTextInputItem {
        itemBuilder.build(self)
    }
}

/// :nodoc:
internal struct EmailElement: BaseFormElement {

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal init(identifier: String,
                  style: FormTextItemStyle) {
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    internal func build(_ itemBuilder: BaseFormBuilder) -> FormTextInputItem {
        itemBuilder.build(self)
    }
}

/// :nodoc:
internal struct PhoneElement: BaseFormElement {

    /// :nodoc:
    internal let style: FormTextItemStyle

    /// :nodoc:
    internal let phoneExtensions: [PhoneExtensionPickerItem]

    /// :nodoc:
    internal var identifier: String

    /// :nodoc:
    internal init(identifier: String,
                  phoneExtensions: [PhoneExtensionPickerItem],
                  style: FormTextItemStyle) {
        self.identifier = identifier
        self.phoneExtensions = phoneExtensions
        self.style = style
    }

    /// :nodoc:
    internal func build(_ itemBuilder: BaseFormBuilder) -> FormPhoneNumberItem {
        itemBuilder.build(self)
    }
}
