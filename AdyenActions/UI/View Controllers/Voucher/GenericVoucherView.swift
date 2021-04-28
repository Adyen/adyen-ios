//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class GenericVoucherView: AbstractVoucherView {

    private lazy var textLabel: UILabel = {
        let label = createLabel(with: model.style.text, text: model.text, identifier: "textLabel")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var amountLabel: UILabel = {
        createLabel(with: model.style.amount, text: model.amount, identifier: "amountLabel")
    }()

    private var model: Model

    internal init(model: Model) {
        self.model = model
        
        super.init(model: model.baseViewModel)
    }

    override internal func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        instructionButton.adyen.round(using: model.instruction.style.button.cornerRounding)
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        instructionButton.adyen.round(using: model.instruction.style.button.cornerRounding)
    }

    private lazy var logoView: NetworkImageView = {
        let imageView = NetworkImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preservesSuperviewLayoutMargins = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        return imageView
    }()

    private lazy var instructionButton: UIButton = {
        let button = UIButton(style: model.instruction.style.button)
        button.setTitle(model.instruction.title, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        button.addTarget(self, action: #selector(openInstructions), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: "instructionButton")

        return button
    }()

    @objc private func openInstructions() {
        guard let url = model.instruction.url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    override internal func createTopView() -> UIView {
        logoView.imageURL = model.logoUrl
        let textLabelWrapper = textLabel.adyen.wrapped(with: UIEdgeInsets(top: 0,
                                                                          left: 16,
                                                                          bottom: 0,
                                                                          right: -16))
        let stackView = UIStackView(arrangedSubviews: [logoView,
                                                       textLabelWrapper,
                                                       instructionButton,
                                                       amountLabel])
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.alignment = .center

        return stackView
    }

    override internal func createBottomView() -> UIView {
        let codeLabel = CopyLabelView(text: model.code, style: model.style.codeText)
        codeLabel.localizationParameters = localizationParameters
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
        view.backgroundColor = UIColor.Adyen.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }

    private func createKeyValueView(key: String, value: String, identifier: String) -> UIView {
        let keyLabel = createLabel(with: model.style.text, text: key, identifier: identifier + "KeyLabel")
        let valueLabel = createLabel(with: model.style.fieldValueText, text: value, identifier: identifier + "ValueLabel")

        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let containerView = stackView.adyen.wrapped(with: UIEdgeInsets(top: 0,
                                                                       left: 16,
                                                                       bottom: 0,
                                                                       right: -16))
        valueLabel.widthAnchor.constraint(lessThanOrEqualTo: containerView.widthAnchor,
                                          multiplier: 0.5).isActive = true

        return containerView
    }

    private func createLabel(with style: TextStyle, text: String?, identifier: String) -> UILabel {
        let label = UILabel(style: style)
        label.text = text
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: identifier)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1

        return label
    }

}
