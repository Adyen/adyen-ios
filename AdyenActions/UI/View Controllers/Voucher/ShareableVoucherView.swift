//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit
@_spi(AdyenInternal) import AdyenUI

internal class ShareableVoucherView: UIView, Localizable {

    internal var localizationParameters: LocalizationParameters?

    private let model: Model

    internal init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        buildUI()
        backgroundColor = model.theme.colors.background
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addVoucherView()
    }

    private func addVoucherView() {
        addSubview(voucherCardView)
        voucherCardView.adyen.anchor(inside: self)
    }
    
    private lazy var voucherCardView: VoucherCardView = {
        let topView = createTopView()
        let bottomView = createBottomView()
        
        return VoucherCardView(
            model: model.separatorModel,
            theme: model.theme,
            topView: topView,
            bottomView: bottomView
        )
    }()
    
    private lazy var textLabel: UILabel = {
        let label = createLabel(with: model.theme.elements.labels.footnote, text: model.text, identifier: "textLabel")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var amountLabel: UILabel = createLabel(
        with: model.theme.elements.labels.bodyEmphasized,
        text: model.amount,
        identifier: "amountLabel"
    )
    
    private lazy var logoView: UIImageView = {
        let imageView = UIImageView()
        let logoSize = CGSize(width: 77.0, height: 50.0)
        imageView.adyen.round(using: .fixed(AdyenUIConstants.imageCornerRadius))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: logoSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: logoSize.height).isActive = true
        
        return imageView
    }()
    
    internal func createTopView() -> UIView {
        logoView.image = model.logo
        let textLabelWrapper = textLabel.adyen.wrapped(
            with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        )
        let stackView = UIStackView(arrangedSubviews: [
            logoView,
            textLabelWrapper,
            amountLabel
        ])
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.alignment = .center
        
        return stackView
    }
    
    internal func createBottomView() -> UIView {
        let codeLabel = AdyenLabel()
        codeLabel.apply(model.theme.elements.labels.subtitle)
        codeLabel.textAlignment = .center
        codeLabel.text = model.code
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
        view.backgroundColor = model.theme.colors.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    
    private func createKeyValueView(key: String, value: String, identifier: String) -> UIView {
        let keyLabel = createLabel(with: model.theme.elements.labels.footnote, text: key, identifier: identifier + "KeyLabel")
        let valueLabel = createLabel(
            with: model.theme.elements.labels.footnoteEmphasized,
            text: value,
            identifier: identifier + "ValueLabel"
        )
        
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = stackView.adyen.wrapped(
            with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        )
        valueLabel.widthAnchor.constraint(
            lessThanOrEqualTo: containerView.widthAnchor,
            multiplier: 0.5
        ).isActive = true
        
        return containerView
    }
    
    private func createLabel(with style: AdyenLabelStyle, text: String?, identifier: String) -> UILabel {
        let label = AdyenLabel()
        label.apply(style)
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        label.text = text
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: identifier)
        
        return label
    }

}

extension ShareableVoucherView {
    
    internal struct VoucherField {
        
        internal var identifier: String
        
        internal var title: String
        
        internal var value: String
        
    }
    
    internal struct Model {
        
        internal let separatorModel: VoucherSeparatorView.Model
        
        internal let text: String
        
        internal let amount: String?
        
        internal let code: String
        
        internal let fields: [VoucherField]
        
        internal let logo: UIImage?
        
        internal let theme: CheckoutTheme
        
    }
    
}
