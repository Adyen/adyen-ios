//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Simple form item that represent a single UImage element.
@_spi(AdyenInternal)
public class FormImageItem: FormItem {

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    public var subitems: [FormItem] = []

    /// The name of the Image.
    public var name: String

    public var identifier: String?

    /// The size of the Image.
    public var size: CGSize

    /// The style of the Image.
    public var style: ImageStyle?
    
    public init(name: String,
                size: CGSize? = nil,
                style: ImageStyle? = nil,
                identifier: String? = nil) {
        self.name = name
        self.size = size ?? .init(width: 46, height: 46)
        self.style = style
        self.identifier = identifier
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        FormImageView(item: self)
    }
}

internal class FormImageView: FormItemView<FormImageItem> {

    internal required init(item: FormImageItem) {
        super.init(item: item)
        renderImage()
    }

    internal func renderImage() {
        let style = item.style ?? ImageStyle(borderColor: nil,
                                             borderWidth: 0,
                                             cornerRadius: 0,
                                             clipsToBounds: false,
                                             contentMode: .center)

        let imageView = UIImageView(style: style)
        self.addSubview(imageView)

        imageView.image = UIImage(named: item.name,
                                  in: Bundle.coreInternalResources,
                                  compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: item.size.width),
            imageView.heightAnchor.constraint(equalToConstant: item.size.height),
            imageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 40.0),
            imageView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: 5.0),
            imageView.widthAnchor.constraint(equalToConstant: item.size.width),
            imageView.centerXAnchor.constraint(equalTo: layoutMarginsGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor)
        ])
    }

}
