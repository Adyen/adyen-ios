//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// View controller with a custom navigation bar for DropIn.

internal final class ModalViewController: UIViewController {
    
    internal let style: NavigationStyle

    private let innerController: UIViewController

    internal weak var delegate: ViewControllerDelegate?

    private let navigationBarHeight: CGFloat = 63.0
    
    private let navBarType: NavigationBarType

    // MARK: - Initializing
    
    /// Initializes the component view controller.
    ///
    /// - Parameter rootViewController: The root view controller to be displayed.
    /// - Parameter style: The navigation level UI style.
    /// - Parameter navBarType: The type of the navigation bar.
    /// - Parameter cancelButtonHandler: An optional callback for the cancel button.
    internal init(rootViewController: UIViewController,
                  style: NavigationStyle = NavigationStyle(),
                  navBarType: NavigationBarType,
                  cancelButtonHandler: ((Bool) -> Void)? = nil) {
        self.innerController = rootViewController
        self.navBarType = navBarType
        self.style = style
        self.cancelButtonHandler = cancelButtonHandler
        
        super.init(nibName: nil, bundle: Bundle(for: ModalViewController.self))
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
    override public func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController()
        view.backgroundColor = style.backgroundColor
    }

    private func addChildViewController() {
        innerController.willMove(toParent: self)
        addChild(innerController)
        view.addSubview(stackView)
        innerController.didMove(toParent: self)
        arrangeConstraints()
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            guard innerController.isViewLoaded else { return .zero }
            let innerSize = innerController.preferredContentSize
            return CGSize(width: innerSize.width,
                          height: navigationBarHeight + innerSize.height + (1.0 / UIScreen.main.scale))
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
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
    
    internal lazy var separator: UIView = {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = getSeparatorColor()
        return separator
    }()
    
    private func getSeparatorColor() -> UIColor {
        switch navBarType {
        case .regular:
            return style.separatorColor ?? UIColor.Adyen.componentSeparator
        case .custom:
            return style.backgroundColor
        }
    }
    
    internal lazy var navBar: UIView = {
        let navBar: AnyNavigationBar
        
        switch navBarType {
        case .regular:
            navBar = getRegularNavBar()
        case let .custom(customNavbar):
            navBar = customNavbar
        }
        
        navBar.onCancelHandler = { [weak self] in self?.didCancel() }
        navBar.translatesAutoresizingMaskIntoConstraints = false
        return navBar
    }()
    
    private func getRegularNavBar() -> AnyNavigationBar {
        ModalToolbar(title: self.innerController.title, style: style)
    }
    
    internal lazy var stackView: UIStackView = {
        let views = [navBar, separator, innerController.view]
        let stackView = UIStackView(arrangedSubviews: views.compactMap { $0 })
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private func didCancel() {
        guard let cancelHandler = cancelButtonHandler else { return }
        
        innerController.resignFirstResponder()
        cancelHandler(isRoot)
    }
    
    // MARK: - Private
    
    private func arrangeConstraints() {
        let separatorHeight: CGFloat = 1.0 / UIScreen.main.scale
        let toolbarHeight = navigationBarHeight - separatorHeight

        stackView.adyen.anchor(inside: view)
        NSLayoutConstraint.activate([
            navBar.heightAnchor.constraint(equalToConstant: toolbarHeight),
            separator.heightAnchor.constraint(equalToConstant: separatorHeight)
        ])
    }
}
