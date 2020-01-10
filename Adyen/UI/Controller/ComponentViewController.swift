//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Components base view controller.
/// :nodoc:
public final class ComponentViewController: UIViewController {
    
    /// Indicates the navigation level style.
    private let style: NavigationStyle
    
    // MARK: - Initializing
    
    /// Initializes the component view controller.
    ///
    /// - Parameter rootViewController: The root view controller to be displayed.
    /// - Parameter style: The navigation level UI style.
    /// - Parameter cancelButtonHandler: An optional callback for the cancel button.
    public init(rootViewController: UIViewController,
                style: NavigationStyle = NavigationStyle(),
                cancelButtonHandler: (() -> Void)? = nil) {
        self.cancelButtonHandler = cancelButtonHandler
        self.rootViewController = rootViewController
        self.style = style
        
        super.init(nibName: nil, bundle: nil)
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    /// :nodoc:
    public override func loadView() {
        view = UIView()
    }
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = style.backgroundColor
        view.tintColor = style.tintColor
        
        // If we're being presented inside a UINavigationController, skip the use of our own navigation controller.
        if parent is UINavigationController {
            display(viewController: rootViewController)
        } else {
            display(viewController: NavigationController(rootViewController: rootViewController, style: style))
        }
    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeingPresented, let cancelHandler = cancelButtonHandler {
            rootViewController.navigationItem.leftBarButtonItem = .cancel(withSelectionHandler: cancelHandler)
        }
    }
    
    // MARK: - Public
    
    // The root view controller that will be displayed
    public private(set) var rootViewController: UIViewController
    
    // MARK: - Private
    
    private var cancelButtonHandler: (() -> Void)?
    
    private func display(viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
        
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
