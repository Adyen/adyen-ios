//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// View controller with a custom navigation bar for DropIn.

internal final class ModalViewController: UIViewController {
    
    private let style: NavigationStyle
    private let innerController: UIViewController
    
    /// :nodoc:
    private var navigationBarHeight: CGFloat = 63.0
    
    // MARK: - Initializing
    
    /// Initializes the component view controller.
    ///
    /// - Parameter rootViewController: The root view controller to be displayed.
    /// - Parameter style: The navigation level UI style.
    /// - Parameter cancelButtonHandler: An optional callback for the cancel button.
    /// - Parameter isDropInRoot: Defines if this controller is a root controller of DropIn.
    internal init(rootViewController: UIViewController,
                  style: NavigationStyle = NavigationStyle(),
                  cancelButtonHandler: ((Bool) -> Void)? = nil) {
        self.cancelButtonHandler = cancelButtonHandler
        self.innerController = rootViewController
        self.style = style
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(rootViewController)
    }
    
    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    internal var isRoot: Bool = false
    
    /// :nodoc:
    internal var cancelButtonHandler: ((Bool) -> Void)?
    
    // MARK: - UIViewController
    
    /// :nodoc:
    override public func loadView() {
        super.loadView()
        titleLabel.text = innerController.title ?? ""
        cancelButton.isHidden = cancelButtonHandler == nil
        
        innerController.willMove(toParent: self)
        addChild(innerController)
        view.addSubview(stackView)
        innerController.didMove(toParent: self)
        arrangeConstraints()
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        innerController.view.layoutIfNeeded()
        view.backgroundColor = style.backgroundColor
        
        cancelButton.tintColor = style.tintColor
        guard let title = titleLabel.text, !title.isEmpty else { return }
        titleLabel.attributedText = NSAttributedString(string: title,
                                                       attributes: [NSAttributedString.Key.font: style.barTitle.font,
                                                                    NSAttributedString.Key.foregroundColor: style.barTitle.color,
                                                                    NSAttributedString.Key.backgroundColor: style.barTitle.backgroundColor])
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            guard innerController.isViewLoaded else { return .zero }
            return CGSize(width: view.bounds.width,
                          height: navigationBarHeight + innerController.preferredContentSize.height)
        }
        
        // swiftlint:disable:next unused_setter_value
        set { assertionFailure("""
        PreferredContentSize is overridden for this view controller.
        getter - returns combined size of an inner content and navigation bar.
        setter - no implemented.
        """)
        }
    }
    
    /// :nodoc:
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.adyen.round(corners: [.topLeft, .topRight], radius: style.cornerRadius)
    }
    
    // MARK: - View elements
    
    internal lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    internal lazy var cancelButton: UIButton = {
        let button: UIButton
        if #available(iOS 13.0, *) {
            button = UIButton(type: UIButton.ButtonType.close)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        } else {
            button = UIButton(type: UIButton.ButtonType.system)
            let cancelText = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
            button.setTitle(cancelText, for: .normal)
            button.setTitleColor(style.tintColor, for: .normal)
        }
        
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        return button
    }()
    
    internal lazy var separator: UIView = {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = style.separatorColor ?? UIColor.AdyenDropIn.componentSeparator
        return separator
    }()
    
    internal lazy var toolbar: UIView = {
        let toolbar = UIStackView(arrangedSubviews: [self.titleLabel, self.cancelButton])
        toolbar.alignment = .center
        toolbar.distribution = .fill
        toolbar.axis = .horizontal
        toolbar.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        toolbar.isLayoutMarginsRelativeArrangement = true
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        toolbar.addSubview(toolbarBackground)
        toolbar.sendSubviewToBack(toolbarBackground)

        anchore(view: toolbar, toView: toolbarBackground)
        
        return toolbar
    }()

    private lazy var toolbarBackground: UIView = {
        let background = UIView(frame: .zero)
        background.backgroundColor = self.style.backgroundColor
        background.translatesAutoresizingMaskIntoConstraints = false

        return background
    }()

    private func anchore(view view1: UIView, toView view2: UIView) {
        let constraints = [
            view1.topAnchor.constraint(equalTo: view2.topAnchor),
            view1.bottomAnchor.constraint(equalTo: view2.bottomAnchor),
            view1.leftAnchor.constraint(equalTo: view2.leftAnchor),
            view1.rightAnchor.constraint(equalTo: view2.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    internal lazy var stackView: UIStackView = {
        let views = [toolbar, separator, innerController.view]
        let stackView = UIStackView(arrangedSubviews: views.compactMap { $0 })
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    @objc private func didCancel() {
        guard let cancelHandler = cancelButtonHandler else { return }
        
        innerController.resignFirstResponder()
        cancelHandler(isRoot)
    }
    
    // MARK: - Private
    
    private func arrangeConstraints() {
        let separatorHeight: CGFloat = 1.0 / UIScreen.main.scale
        let toolbarHeight = navigationBarHeight - separatorHeight
        
        let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight),
            separator.heightAnchor.constraint(equalToConstant: separatorHeight),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint
        ])
    }
}
