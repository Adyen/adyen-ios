//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
public final class ContainerView: UIView {
    
    private let body: UIView
    private let edgeInsets: UIEdgeInsets
    
    /// :nodoc:
    public init(body: UIView, padding: UIEdgeInsets = .zero) {
        self.body = body
        self.edgeInsets = padding
        super.init(frame: .zero)
        
        body.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(body)
        setupConstraints()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    public func setupConstraints() {
        let constraints = [
            body.topAnchor.constraint(equalTo: self.topAnchor, constant: edgeInsets.top),
            body.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -edgeInsets.bottom),
            body.leftAnchor.constraint(equalTo: self.leftAnchor, constant: edgeInsets.left),
            body.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -edgeInsets.right)
        ]
        constraints.forEach { $0.priority = .defaultHigh }
        NSLayoutConstraint.activate(constraints)
    }
    
}
