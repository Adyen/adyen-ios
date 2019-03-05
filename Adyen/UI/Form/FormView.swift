//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormView: UIScrollView {
    public init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        footerStackView.addArrangedSubview(payButton)
        footerStackView.addArrangedSubview(payButtonSubtitle)
        addSubview(footerStackView)
        addSubview(formStackView)
        
        configureConstraints()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public private(set) lazy var payButton: UIButton = {
        let payButton = Appearance.shared.payButton()
        payButton.isEnabled = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        return payButton
    }()
    
    public private(set) lazy var payButtonSubtitle: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.titleAttributes)
                if #available(iOS 11.0, *) {
                    dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.formAttributes.titleAttributes, textStyle: .largeTitle)
                } else {
                    dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.formAttributes.titleAttributes, textStyle: .title1)
                }
            }
        }
    }
    
    public func addFormElement(_ element: UIView) {
        // Form Section should handle it's own margins
        if element is FormSection {
            formStackView.addArrangedSubview(element)
            return
        }
        
        element.backgroundColor = UIColor.clear
        
        // Embed in a stack view so that we can set margins.
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(element)
        formStackView.addArrangedSubview(stackView)
        
        func containsFormField(_ view: UIView) -> Bool {
            if view is FormTextField || view is FormPickerField {
                return true
            } else {
                for subview in view.subviews where subview is FormTextField || subview is FormPickerField {
                    return true
                }
            }
            
            return false
        }
        
        if containsFormField(element) {
            addSeparator()
        }
    }
    
    public func addFooterElement(_ element: UIView) {
        footerStackView.addArrangedSubview(element)
    }
    
    // MARK: - Internal
    
    internal var firstResponder: UIResponder? {
        func allSubviews(_ view: UIView) -> [UIView] {
            var subviews = [UIView]()
            
            for subview in view.subviews {
                subviews.append(contentsOf: allSubviews(subview))
                subviews.append(subview)
            }
            
            return subviews
        }
        
        let subviews = allSubviews(formStackView)
        return subviews.first(where: { $0.canBecomeFirstResponder })
    }
    
    // MARK: - Private
    
    private let margin: CGFloat = 16
    
    private let dynamicTypeController = DynamicTypeController()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()
    
    private lazy var formStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()
    
    private lazy var footerStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        stackView.spacing = 12.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()
    
    private func configureConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        
        var constraints: [NSLayoutConstraint] = []
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -2 * margin)
        ]
        constraints.append(contentsOf: titleLabelConstraints)
        
        let stackViewConstraints = [
            formStackView.firstBaselineAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0),
            formStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            formStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            formStackView.widthAnchor.constraint(equalTo: widthAnchor)
        ]
        constraints.append(contentsOf: stackViewConstraints)
        
        let footerConstraints = [
            footerStackView.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 32),
            footerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
        ]
        constraints.append(contentsOf: footerConstraints)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addSeparator() {
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Appearance.shared.formAttributes.separatorColor
        
        let height = 1.0 / UIScreen.main.scale
        separator.heightAnchor.constraint(equalToConstant: height).isActive = true
        formStackView.addArrangedSubview(separator)
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
}
