//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A form item that displays a card image loaded from a URL with shadow styling.
@_spi(AdyenInternal)
public class FormCardImageItem: FormItem {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    public var subitems: [FormItem] = []

    /// The URL of the card image.
    public var imageURL: URL?

    public var identifier: String?

    /// The size of the card image. Defaults to 150×94pt.
    public var size: CGSize

    /// The corner radius of the card image. Defaults to 5pt.
    public var cornerRadius: CGFloat

    /// Initializes the form card image item.
    ///
    /// - Parameters:
    ///   - imageURL: The URL of the card image to display.
    ///   - size: The size of the card image. Defaults to 150×94pt.
    ///   - cornerRadius: The corner radius of the card image. Defaults to 5pt.
    ///   - identifier: An optional accessibility identifier.
    public init(
        imageURL: URL?,
        size: CGSize = CGSize(width: 150, height: 94),
        cornerRadius: CGFloat = 5,
        identifier: String? = nil
    ) {
        self.imageURL = imageURL
        self.size = size
        self.cornerRadius = cornerRadius
        self.identifier = identifier
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
