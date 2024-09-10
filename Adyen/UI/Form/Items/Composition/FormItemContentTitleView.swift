//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public class FormItemContentTitleView: UIView {
    
    internal lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        return titleLabel
    }()
    
    internal let accessoryView: UIView?
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public init(
        title: AdyenObservable<String?>,
        accessoryView: UIView? = nil
    ) {
        self.accessoryView = accessoryView
        super.init(frame: .zero)
        
        titleLabel.text = title.wrappedValue
        bind(title, to: titleLabel, at: \.text)
        
        setupContent()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FormItemContentTitleView {
    func setupContent() {
        addSubview(contentStackView)
        contentStackView.adyen.anchor(inside: self)
        
        contentStackView.addArrangedSubview(titleLabel)
        if let accessoryView {
            let spacer = UIView()
            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            contentStackView.addArrangedSubview(spacer)
            
            contentStackView.addArrangedSubview(accessoryView)
        }
        
        backgroundColor = .red
    }
}

@_spi(AdyenInternal)
extension FormItemContentTitleView: AdyenObserver {}
