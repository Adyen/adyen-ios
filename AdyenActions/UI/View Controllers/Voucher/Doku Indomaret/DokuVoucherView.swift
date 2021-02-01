//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension DokuVoucherView {

    internal struct VoucherField {

        internal var identifier: String

        internal var title: String

        internal var value: String
    }

    internal struct Model {

        internal let title: String

        internal let subtitle: String?

        internal let code: String

        internal let fields: [VoucherField]

        internal let logoUrl: URL

        internal var style = Style()

        internal struct Style {

            internal var title = TextStyle(font: .systemFont(ofSize: 13),
                                           color: UIColor.Adyen.componentLabel,
                                           textAlignment: .center)

            internal var subtitle = TextStyle(font: .boldSystemFont(ofSize: 16),
                                              color: UIColor.Adyen.componentLabel,
                                              textAlignment: .center)

            internal var codeText = TextStyle(font: .boldSystemFont(ofSize: 24),
                                              color: UIColor.Adyen.componentLabel,
                                              textAlignment: .center)

            internal var fieldValueText = TextStyle(font: .boldSystemFont(ofSize: 13),
                                                    color: UIColor.Adyen.componentLabel,
                                                    textAlignment: .center)
        }

        internal var voucherSeparator: VoucherSeparatorView.Model
    }
}

internal final class DokuVoucherView: AbstractVoucherView {

    private lazy var titleLabel: UILabel = {
        createLabel(with: model.style.title, text: model.title, identifier: "titleLabel")
    }()

    private lazy var subtitleLabel: UILabel = {
        createLabel(with: model.style.subtitle, text: model.subtitle, identifier: "subtitleLabel")
    }()

    private let model: Model

    internal init(model: Model) {
        self.model = model
        super.init(model: model.voucherSeparator)
    }

    private lazy var logoView: NetworkImageView = {
        let imageView = NetworkImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preservesSuperviewLayoutMargins = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        return imageView
    }()

    override internal func createTopView() -> UIView {
        logoView.imageURL = model.logoUrl
        let stackView = UIStackView(arrangedSubviews: [logoView, titleLabel, subtitleLabel])
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.alignment = .center

        return stackView
    }

    override internal func createBottomView() -> UIView {
        let codeLabel = CopyLabelView(text: model.code, style: model.style.codeText)
        let views = [codeLabel] + model.fields.flatMap {
            [createSeparator(), createKeyValueView(key: $0.title, value: $0.value, identifier: $0.identifier)]
        }
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.alignment = .center

        stackView.arrangedSubviews.forEach { [stackView] view in
            view.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        }

        return stackView
    }

    private func createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xE6E9EB)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }

    private func createKeyValueView(key: String, value: String, identifier: String) -> UIView {
        let keyLabel = createLabel(with: model.style.title, text: key, identifier: identifier + "KeyLabel")
        let valueLabel = createLabel(with: model.style.fieldValueText, text: value, identifier: identifier + "ValueLabel")

        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView()
        containerView.addSubview(stackView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.adyen.anchore(inside: containerView, with: UIEdgeInsets(top: 0,
                                                                          left: 16,
                                                                          bottom: 0,
                                                                          right: -16))

        return containerView
    }

    private func createLabel(with style: TextStyle, text: String?, identifier: String) -> UILabel {
        let label = UILabel()
        label.font = style.font
        label.adjustsFontForContentSizeCategory = true
        label.textColor = style.color
        label.textAlignment = style.textAlignment
        label.backgroundColor = style.backgroundColor
        label.text = text
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.dokuVoucher", postfix: identifier)

        return label
    }

}
