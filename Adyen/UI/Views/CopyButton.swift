//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@_spi(AdyenInternal)
public class CopyButton: UIButton {
    
    // MARK: - Properties
    
    private let title: String
    private let onCopyTitle: String
    private let value: String?
    
    // MARK: - Initializers
    
    public init(
        title: String,
        onCopyTitle: String,
        value: String?,
        style: ButtonStyle
    ) {
        self.title = title
        self.onCopyTitle = onCopyTitle
        self.value = value
        super.init(frame: .zero)
        
        adyen.apply(style)
        setup()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setup() {
        setTitle(title, for: .normal)
        addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside)
    }
    
    @objc private func copyToClipboard() {
        guard let value else { return }
        UIPasteboard.general.string = value
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let originalTitle = title(for: .normal)
        
        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.setTitle(self.onCopyTitle, for: .normal)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.backgroundColor = UIColor.Adyen.defaultBlue
                self.setTitle(originalTitle, for: .normal)
            })
        }
    }
}
