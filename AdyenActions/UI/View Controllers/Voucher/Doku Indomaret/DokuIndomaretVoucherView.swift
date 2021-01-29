//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension DokuIndomaretVoucherView {
    internal struct Model {

        internal var title: String?

        internal var subtitle: String?

        internal var code: String

        internal var expirationTitle: String

        internal var expirationValue: String

        internal var emailTitle: String

        internal var emailValue: String

        internal var titleStyle = TextStyle(font: .systemFont(ofSize: 13),
                                            color: UIColor(hex: 0x00112C),
                                            textAlignment: .center)

        internal var subtitleStyle = TextStyle(font: .boldSystemFont(ofSize: 16),
                                               color: UIColor(hex: 0x00112C),
                                               textAlignment: .center)

        internal var codeTextStyle = TextStyle(font: .boldSystemFont(ofSize: 24),
                                               color: UIColor(hex: 0x00112C),
                                               textAlignment: .center)

        internal var valueTextStyle = TextStyle(font: .boldSystemFont(ofSize: 13),
                                                color: UIColor(hex: 0x00112C),
                                                textAlignment: .center)

        internal var voucherSeparator: VoucherSeparatorView.Model
    }
}

internal final class DokuIndomaretVoucherView: AbstractVoucherView {

    private lazy var titleLabel: UILabel = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "titleLabel")

        return createLabel(with: model.titleStyle, text: model.title, identifier: identifier)
    }()

    private lazy var subtitleLabel: UILabel = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "subtitleLabel")

        return createLabel(with: model.subtitleStyle, text: model.subtitle, identifier: identifier)
    }()

    private let model: Model

    internal init(model: Model, onShare: @escaping (UIView) -> Void) {
        self.model = model
        super.init(onShare: onShare)
    }

    private lazy var logoView: NetworkImageView = {
        let imageView = NetworkImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preservesSuperviewLayoutMargins = true
        imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true
        imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 64).isActive = true

        return imageView
    }()

    override internal func createTopView() -> UIView {
        logoView.imageURL = URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/images/logos/small/doku@3x.png")
        let stackView = UIStackView(arrangedSubviews: [logoView, titleLabel, subtitleLabel])
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.alignment = .center

        return stackView
    }

    override internal func createBottomView() -> UIView {
        let codeLabel = CopyLabelView(text: model.code, style: model.codeTextStyle)
        let expirationView = createKeyValueView(key: model.expirationTitle, value: model.expirationValue, identifier: "expiration")
        let emailView = createKeyValueView(key: model.emailTitle, value: model.emailValue, identifier: "email")
        let stackView = UIStackView(arrangedSubviews: [codeLabel, createSeparator(), expirationView, createSeparator(), emailView])
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
        let keyLabel = createLabel(with: model.titleStyle, text: key, identifier: identifier + "KeyLabel")
        let valueLabel = createLabel(with: model.valueTextStyle, text: value, identifier: identifier + "ValueLabel")

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
        label.accessibilityIdentifier = identifier

        return label
    }

}
