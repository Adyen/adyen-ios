//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public protocol BaseFormElement {

    /// :nodoc:
    associatedtype StyleType: ViewStyle

    /// :nodoc:
    associatedtype ItemType: FormItem

    /// :nodoc:
    var identifier: String { get }

    /// :nodoc:
    var style: StyleType { get }

    /// :nodoc:
    func build(_ itemBuilder: AnyFormBuilder) -> ItemType
}

/// :nodoc:
public struct FirstNameElement: BaseFormElement {

    /// :nodoc:
    public let style: FormTextItemStyle

    /// :nodoc:
    public var identifier: String

    /// :nodoc:
    public init(identifier: String,
                style: FormTextItemStyle) {
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    public func build(_ itemBuilder: AnyFormBuilder) -> FormTextInputItem {
        itemBuilder.build(self)
    }
}

/// :nodoc:
public struct LastNameElement: BaseFormElement {

    /// :nodoc:
    public let style: FormTextItemStyle

    /// :nodoc:
    public var identifier: String

    /// :nodoc:
    public init(identifier: String,
                style: FormTextItemStyle) {
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    public func build(_ itemBuilder: AnyFormBuilder) -> FormTextInputItem {
        itemBuilder.build(self)
    }
}

/// :nodoc:
public struct EmailElement: BaseFormElement {

    /// :nodoc:
    public let style: FormTextItemStyle

    /// :nodoc:
    public var identifier: String

    /// :nodoc:
    public init(identifier: String,
                style: FormTextItemStyle) {
        self.identifier = identifier
        self.style = style
    }

    /// :nodoc:
    public func build(_ itemBuilder: AnyFormBuilder) -> FormTextInputItem {
        itemBuilder.build(self)
    }
}

/// :nodoc:
public struct PhoneElement: BaseFormElement {

    /// :nodoc:
    public let style: FormTextItemStyle

    /// :nodoc:
    public let phoneExtensions: [PhoneExtensionPickerItem]

    /// :nodoc:
    public var identifier: String

    /// :nodoc:
    public init(identifier: String,
                phoneExtensions: [PhoneExtensionPickerItem],
                style: FormTextItemStyle) {
        self.identifier = identifier
        self.phoneExtensions = phoneExtensions
        self.style = style
    }

    /// :nodoc:
    public func build(_ itemBuilder: AnyFormBuilder) -> FormPhoneNumberItem {
        itemBuilder.build(self)
    }
}
