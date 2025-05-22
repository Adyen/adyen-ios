//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

extension FormCardNumberItemView {
    private enum Constants {
        static let buttonSpacing: CGFloat = 10
        static let imageName = "camera.fill"
    }

    func makeCardScanAccessoryView(title: String, _ selector: Selector) -> UIView {
        let accessoryView = UIInputView(frame: .zero, inputViewStyle: .keyboard)
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let scanButton = UIButton(type: .system)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.setTitle(title, for: .normal)
        scanButton.tintColor = .systemBlue

        if #available(iOS 13.0, *) {
            scanButton.setImage(UIImage(systemName: Constants.imageName), for: .normal)
        }
        
        scanButton.imageView?.contentMode = .scaleAspectFit
        scanButton.contentHorizontalAlignment = .center
        
        let spacing = Constants.buttonSpacing
        scanButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2, bottom: 0, right: spacing / 2)
        scanButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: -spacing / 2)
        scanButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        
        scanButton.addTarget(self, action: selector, for: .touchUpInside)
        
        accessoryView.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: accessoryView.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor),
            scanButton.widthAnchor.constraint(lessThanOrEqualTo: accessoryView.widthAnchor, multiplier: 0.8)
        ])
        
        return accessoryView
    }
}
