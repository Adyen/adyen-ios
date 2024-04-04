//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package final class CancellingToolBar: ModalToolbar {

    private let style: NavigationStyle
    private let title: String?

    override public init(title: String?, style: NavigationStyle) {
        self.style = style
        self.title = title
        super.init(title: title, style: style)
    }

    private func customizeCancelButton() -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.system)
        let cancelText = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
        button.setTitle(cancelText, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.setTitleColor(style.tintColor, for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        return button
    }

    override internal var cancelButton: UIButton {
        get {
            customizeCancelButton()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            _ = customizeCancelButton()
        }
    }
}
