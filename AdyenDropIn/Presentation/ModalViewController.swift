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

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.adyen.round(corners: [.topLeft, .topRight], radius: style.cornerRadius)
    }
    
    // MARK: - View elements

    internal lazy var stackView: UIStackView = {
        let views = [innerController.view]
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
        stackView.adyen.anchor(inside: view)
    }
}
