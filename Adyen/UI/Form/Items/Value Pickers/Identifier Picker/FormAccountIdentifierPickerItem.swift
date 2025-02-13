//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A wrapper struct to use as item in ``FormIdentifierPickerItem``
@_spi(AdyenInternal)
public struct FormIdentifierPickerElement: CustomStringConvertible, Equatable {

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

    public init(
        preselectedIdentifier: FormIdentifierPickerElement,
        selectableIdentifiers: [FormIdentifierPickerElement],
        style: FormTextItemStyle
    ) {
        super.init(
            preselectedValue: .init(identifier: preselectedIdentifier.identifier, element: preselectedIdentifier),
            selectableValues: selectableIdentifiers.map { $0.toBaseFormPickerElement() },
            style: style
        )
    }

    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

private extension FormIdentifierPickerElement {

    func toBaseFormPickerElement() -> BasePickerElement<FormIdentifierPickerElement> {
        .init(identifier: identifier, element: self)
    }
}
