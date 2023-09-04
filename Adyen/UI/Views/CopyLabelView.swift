//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
public final class CopyLabelView: UIView, Localizable {

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    private let style: TextStyle

    private let text: String

    private lazy var label: UILabel = {
        let label = UILabel(style: style)
        label.text = text
        label.lineBreakMode = .byTruncatingMiddle
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "textLabel")

        return label
    }()

    /// :nodoc:
    public init(text: String, style: TextStyle) {
        self.text = text
        self.style = style
        super.init(frame: .zero)
        addSubview(label)
        label.adyen.anchor(inside: layoutMarginsGuide)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didHideCopyMenu),
            name: UIMenuController.didHideMenuNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTap() {
        guard let superview else { return }
        becomeFirstResponder()
        let menuController = UIMenuController.shared
        let copyItem = UIMenuItem(title: localizedString(.buttonCopy, localizationParameters), action: #selector(handleCopy))
        menuController.menuItems = [copyItem]
        menuController.setTargetRect(frame, in: superview)
        menuController.setMenuVisible(true, animated: true)
        backgroundColor = UIColor.Adyen.lightGray
    }

    /// :nodoc:
    override public var canBecomeFirstResponder: Bool { true }

    @objc private func handleCopy() {
        let pastBoard = UIPasteboard.general
        pastBoard.string = text
        backgroundColor = .clear
    }

    @objc private func didHideCopyMenu() {
        backgroundColor = .clear
    }

    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
    }

}
