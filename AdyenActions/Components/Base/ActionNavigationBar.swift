//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol AnyActionNavigationBar: AnyNavigationBar {
    
    var model: AnyActionNavigationBarModel { get }
    
    var style: AnyActionNavigationBarStyle { get }
    
    var leadingButtonHandler: (() -> Void)? { get }
    
    var trailingButtonHandler: (() -> Void)? { get }
}

internal protocol AnyActionNavigationBarModel {
    
    var leadingButtonTitle: String? { get }
    
    var trailingButtonTitle: String? { get }
}

internal protocol AnyActionNavigationBarStyle {
    
    var leadingButton: ButtonStyle? { get }
    
    var trailingButton: ButtonStyle? { get }
    
    var backgroundColor: UIColor { get }
}

internal class ActionNavigationBar: UIView, AnyActionNavigationBar {
    
    internal let model: AnyActionNavigationBarModel
    
    internal let style: AnyActionNavigationBarStyle
    
    internal var leadingButtonHandler: (() -> Void)?
    
    internal var trailingButtonHandler: (() -> Void)?
    
    internal var onCancelHandler: (() -> Void)?
    
    internal init(model: AnyActionNavigationBarModel, style: AnyActionNavigationBarStyle) {
        self.model = model
        self.style = style
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = style.backgroundColor
        
        let stackView = UIStackView()
        addSubview(stackView)
        
        stackView.adyen.anchor(inside: self)
        stackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        
        if let leadingButtonStyle = style.leadingButton, let leadingButtonTitle = model.leadingButtonTitle {
            let leadingButton = UIButton(style: leadingButtonStyle)
            leadingButton.translatesAutoresizingMaskIntoConstraints = false
            leadingButton.setTitle(leadingButtonTitle, for: .normal)
            leadingButton.addTarget(self, action: #selector(onLeadingButtonTap), for: .touchUpInside)
            leadingButton.contentHorizontalAlignment = .leading
            
            stackView.addArrangedSubview(leadingButton)
        }
        
        if let trailingButtonStyle = style.trailingButton, let trailingButtonTitle = model.trailingButtonTitle {
            let trailingButton = UIButton(style: trailingButtonStyle)
            trailingButton.translatesAutoresizingMaskIntoConstraints = false
            trailingButton.setTitle(trailingButtonTitle, for: .normal)
            trailingButton.addTarget(self, action: #selector(onTrailingButtonTap), for: .touchUpInside)
            trailingButton.contentHorizontalAlignment = .trailing
            
            stackView.addArrangedSubview(trailingButton)
        }
    }
    
    @objc private func onLeadingButtonTap() {
        leadingButtonHandler?()
    }
    
    @objc private func onTrailingButtonTap() {
        trailingButtonHandler?()
    }
}

extension ActionNavigationBar {
    internal struct Model: AnyActionNavigationBarModel {
        
        internal let leadingButtonTitle: String?
        
        internal let trailingButtonTitle: String?
    }
    
    internal struct Style: AnyActionNavigationBarStyle {
        
        internal let leadingButton: ButtonStyle?
        
        internal let trailingButton: ButtonStyle?
        
        internal let backgroundColor: UIColor
    }
}
