//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension FormCardNumberItemView {
    func makeCardScanAccessoryView(_ selector: Selector) -> UIView {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        accessoryView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("Scan your card", for: .normal)
        scanButton.addTarget(self, action: selector, for: .touchUpInside)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        
        accessoryView.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: accessoryView.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor)
        ])
        
        return accessoryView
    }
}
