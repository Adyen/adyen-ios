//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

/// :nodoc:
open class FormSection: UIStackView {
    public init() {
        super.init(frame: CGRect.zero)
        axis = .vertical
        
        addArrangedSubview(UIView(frame: CGRect.zero))
        layoutMargins = UIEdgeInsets(top: margin, left: 0, bottom: 0, right: 0)
        isLayoutMarginsRelativeArrangement = true
        
        addFormElement(titleLabel)
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Open
    
    open func addFormElement(_ element: UIView) {
        element.backgroundColor = UIColor.clear
        
        // Embed in a stack view so that we can set margins.
        let stackView = UIStackView()
        let verticalMargin: CGFloat = element == titleLabel ? 8 : 0
        stackView.layoutMargins = UIEdgeInsets(top: verticalMargin, left: margin, bottom: verticalMargin, right: margin)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(element)
        addArrangedSubview(stackView)
        
        let padding = element == titleLabel ? 0 : margin
        addSeparator(leftPadding: padding)
    }
    
    // MARK: - Public
    
    public var title: String? {
        didSet {
            guard let title = title else {
                return
            }
            
            let attributedTitle = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.sectionTitleAttributes)
            titleLabel.attributedText = attributedTitle
            dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.formAttributes.sectionTitleAttributes, textStyle: .body)
            accessibilityLabel = title
        }
    }
    
    // MARK: - Private
    
    private let margin: CGFloat = 16
    private let dynamicTypeController = DynamicTypeController()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private func addSeparator(leftPadding: CGFloat = 0) {
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Appearance.shared.formAttributes.separatorColor
        
        let height = 1.0 / UIScreen.main.scale
        separator.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(separator)
        addArrangedSubview(stackView)
    }
}
