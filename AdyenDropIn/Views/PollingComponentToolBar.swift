//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal class PollingComponentToolBar: ModalToolbar {

    private let style: NavigationStyle
    private let title: String?

    internal override init(title: String?, style: NavigationStyle) {
        self.style = style
        self.title = title
        super.init(title: title, style: style)
    }

    private func customizeCancelButton() -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.system)
        let cancelText = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
        button.setTitle(cancelText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17.0)
        button.setTitleColor(style.tintColor, for: .normal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        return button
    }

    override internal var cancelButton: UIButton {
        get {
            return customizeCancelButton()
        }
        // swiftlint:disable:next unused_setter_value
        set {
            _ = customizeCancelButton()
        }
    }

    internal func getPollingComponentNavBar() -> AnyNavigationBar {
       PollingComponentToolBar(title: title, style: style)
    }

}
