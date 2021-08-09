//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// :nodoc:
final internal class VoucherNavBar: UIView, AnyNavigationBar {
    
    /// :nodoc:
    public var leadingButtonHandler: (() -> Void)?
    
    /// :nodoc:
    public var trailingButtonHandler: (() -> Void)?
    
    /// :nodoc:
    public var onCancelHandler: (() -> Void)?
    
    /// :nodoc:
    private var model: Model
    
    /// :nodoc:
    public init(model: Model) {
        self.model = model
        
        super.init(frame: .zero)
        
        buildUI()
    }
    
    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        backgroundColor = model.style.backgroundColor
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackView.adyen.anchor(inside: self)
        stackView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let editButton = UIButton(style: model.style.editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle(model.editButtonTitle, for: .normal)
        editButton.addTarget(self, action: #selector(onEditButtonTap), for: .touchUpInside)
        
        let doneButton = UIButton(style: model.style.doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle(model.doneButtonTitle, for: .normal)
        doneButton.addTarget(self, action: #selector(onDoneButtonTap), for: .touchUpInside)
        
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(doneButton)
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
    }
    
    @objc private func onEditButtonTap() {
        onCancelHandler?()
    }
    
    @objc private func onDoneButtonTap() {
        trailingButtonHandler?()
    }
    
}

extension VoucherNavBar {
    
    /// :nodoc
    internal struct Model {
        
        internal let editButtonTitle: String
        
        internal let doneButtonTitle: String
        
        internal let style: Style
        
        internal struct Style {
            
            internal let editButton: ButtonStyle
            
            internal let doneButton: ButtonStyle
            
            internal let backgroundColor: UIColor
            
        }
        
    }
}
