//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Generic FormItemContentView that arranges the content in a VStack
@_spi(AdyenInternal)
public class FormItemContentView: UIView {
    
    internal let content: [UIView]
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8.0
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public init(content: [UIView]) {
        self.content = content
        super.init(frame: .zero)
        
        setupContent()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContent() {
        addSubview(contentStackView)
        contentStackView.adyen.anchor(inside: self)
        content.forEach { contentStackView.addArrangedSubview($0) }
        
        backgroundColor = .lightGray
    }
}
