//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import UIKit

/// View controller with a custom navigation bar for DropIn.
internal final class ModalViewController: UIViewController {
    private enum Constants {
        static let navigationBarHeight: CGFloat = 63
        static var separatorHeight: CGFloat {
            1.0 / UIScreen.main.scale
        }
    }
    
    internal let style: NavigationStyle

    private let innerController: UIViewController

    internal weak var delegate: ViewControllerDelegate?

    private var navigationBarHeight: CGFloat {
        guard case .regular = navBarType else { return Constants.navigationBarHeight }
        let currentWidth = viewIfLoaded?.bounds.width ?? 0
        let width = currentWidth > 0 ? currentWidth : Dimensions.expectedWidth(for: viewIfLoaded?.window)
        let fittingHeight = navBar.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        let toolbarContentHeight = fittingHeight - navBar.safeAreaInsets.top - navBar.safeAreaInsets.bottom
        return max(Constants.navigationBarHeight, toolbarContentHeight + Constants.separatorHeight)
    }
    
    private let navBarType: NavigationBarType
    private var laidOutToolbarHeight: CGFloat?

    // MARK: - Initializing
    
    /// Initializes the component view controller.
    ///
    /// - Parameter rootViewController: The root view controller to be displayed.
    /// - Parameter style: The navigation level UI style.
    /// - Parameter navBarType: The type of the navigation bar.
    /// - Parameter cancelButtonHandler: An optional callback for the cancel button.
    internal init(
        rootViewController: UIViewController,
        style: NavigationStyle = NavigationStyle(),
        navBarType: NavigationBarType,
        cancelButtonHandler: ((Bool) -> Void)? = nil
    ) {
        self.innerController = rootViewController
        self.navBarType = navBarType
        self.style = style
        self.cancelButtonHandler = cancelButtonHandler
        
        super.init(nibName: nil, bundle: Bundle(for: ModalViewController.self))
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var isRoot: Bool = false
    
    internal var cancelButtonHandler: ((Bool) -> Void)?
    
    // MARK: - UIViewController
    
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
            return CGSize(
                width: innerSize.width,
                height: navigationBarHeight + innerSize.height + Constants.separatorHeight
            )
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns combined size of an inner content and navigation bar.
        setter - no implemented.
        """)
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.adyen.round(corners: [.topLeft, .topRight], radius: style.cornerRadius)
        notifyToolbarHeightChangeIfNeeded()
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
    
    private var minimumToolbarHeight: CGFloat {
        Constants.navigationBarHeight - Constants.separatorHeight
    }

    private func arrangeConstraints() {
        stackView.adyen.anchor(inside: view)
        NSLayoutConstraint.activate(navBarHeightConstraints + [
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight)
        ])
    }

    private var navBarHeightConstraints: [NSLayoutConstraint] {
        switch navBarType {
        case .regular:
            let preferredHeight = navBar.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: minimumToolbarHeight
            )
            // The toolbar content uses required priorities, so it can grow past the default height at large text sizes.
            preferredHeight.priority = .required - 1
            return [
                preferredHeight,
                navBar.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: minimumToolbarHeight)
            ]
        case .custom:
            return [navBar.heightAnchor.constraint(equalToConstant: minimumToolbarHeight)]
        }
    }

    private func notifyToolbarHeightChangeIfNeeded() {
        guard case .regular = navBarType else { return }
        let height = navBar.frame.maxY - view.safeAreaInsets.top
        guard height != laidOutToolbarHeight else { return }
        let isInitialLayout = laidOutToolbarHeight == nil
        laidOutToolbarHeight = height
        guard !isInitialLayout else { return }
        (navigationController as? PreferredContentSizeConsumer)?.didUpdatePreferredContentSize()
    }
}
