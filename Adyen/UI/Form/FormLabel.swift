//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormLabel: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        configureConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public var text: String? {
        didSet {
            guard let text = text else {
                return
            }
            
            let attributedTitle = NSAttributedString(string: text, attributes: Appearance.shared.textAttributes)
            label.attributedText = attributedTitle
            dynamicTypeController.observeDynamicType(for: label, withTextAttributes: Appearance.shared.textAttributes, textStyle: .body)
            accessibilityLabel = text
        }
    }
    
    // MARK: - Private
    
    private let dynamicTypeController = DynamicTypeController()
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    private func configureConstraints() {
        let constraints = [
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
