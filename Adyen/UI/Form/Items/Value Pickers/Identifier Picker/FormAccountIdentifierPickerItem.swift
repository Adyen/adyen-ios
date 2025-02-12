//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal)
public protocol AccountIdentifier: CustomStringConvertible, Equatable {
    var identifier: String { get }
    var title: String { get }
}

/// A wrapper struct to use as item in ``FormIdentifierPickerItem``
@_spi(AdyenInternal)
public struct FormIdentifierPickerElement: AccountIdentifier {

    public let identifier: String
    public let title: String
    public var description: String {
        title
    }

    public init(identifier: String, title: String) {
        self.identifier = identifier
        self.title = title
    }
}

/// A identifier picker form item
@_spi(AdyenInternal)
public final class FormIdentifierPickerItem: BaseFormPickerItem<FormIdentifierPickerElement> {

    override public init(
        preselectedValue: BasePickerElement<FormIdentifierPickerElement>,
        selectableValues: [BasePickerElement<FormIdentifierPickerElement>],
        style: FormTextItemStyle
    ) {
        super.init(
            preselectedValue: preselectedValue,
            selectableValues: selectableValues,
            style: style
        )
    }

    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
