//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A wrapper struct to use as item in ``FormStringPickerItem``
@_spi(AdyenInternal)
public struct FormStringPickerElement: CustomStringConvertible, Equatable {

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
open class FormStringPickerItem: BaseFormPickerItem<FormStringPickerElement> {

    public init(
        preselectedStringValue: FormStringPickerElement,
        selectableStringValues: [FormStringPickerElement],
        style: FormTextItemStyle
    ) {
        super.init(
            preselectedValue: .init(
                identifier: preselectedStringValue.identifier,
                element: preselectedStringValue
            ),
            selectableValues: selectableStringValues
                .map { $0.toBaseFormPickerElement() },
            style: style
        )
    }

    override open func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

private extension FormStringPickerElement {

    func toBaseFormPickerElement() -> BasePickerElement<FormStringPickerElement> {
        .init(identifier: identifier, element: self)
    }
}
