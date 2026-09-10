//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormTextItemView
#endif
import UIKit

extension FormCardNumberItemView {
    private enum Constants {
        static let height: CGFloat = 44
        static let buttonSpacing: CGFloat = 10
        static let imageName = "camera.fill"
    }

    /// Re-resolves the scan button's background color.
    ///
    /// The accessory view is hosted in the system's keyboard window, which doesn't reliably resolve dynamic
    /// colors (e.g. `.systemBackground`) against the presenting view's trait collection, so this should be
    /// called with an already-resolved color while `self` is mounted in the real window (e.g. `textFieldDidBeginEditing`).
    internal func updateCardScanAccessoryViewBackgroundColor(_ backgroundColor: UIColor) {
        textField.inputAccessoryView?.subviews.first?.backgroundColor = backgroundColor
    }

    internal func makeCardScanAccessoryView(title: String, backgroundColor: UIColor, _ selector: Selector) -> UIView {
        let accessoryView = UIView(frame: .zero)
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.heightAnchor.constraint(equalToConstant: Constants.height).isActive = true

        let scanButton = makeScanButton(title: title, backgroundColor: backgroundColor, selector: selector)
        accessoryView.addSubview(scanButton)
        scanButton.adyen.anchor(inside: accessoryView)

        return accessoryView
    }

    private func makeScanButton(title: String, backgroundColor: UIColor, selector: Selector) -> UIButton {
        let scanButton = UIButton(type: .system)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.setTitle(title, for: .normal)
        scanButton.tintColor = .systemBlue
        scanButton.backgroundColor = backgroundColor
        scanButton.setImage(UIImage(systemName: Constants.imageName), for: .normal)
        scanButton.imageView?.contentMode = .scaleAspectFit
        scanButton.contentHorizontalAlignment = .center

        let spacing = Constants.buttonSpacing
        scanButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2, bottom: 0, right: spacing / 2)
        scanButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing / 2, bottom: 0, right: -spacing / 2)
        scanButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)

        scanButton.addTarget(self, action: selector, for: .touchUpInside)
        return scanButton
    }
}
