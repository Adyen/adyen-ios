//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Components base view controller.
/// :nodoc:
public final class ComponentViewController: UIViewController {
    
    // MARK: - Initializing
    
    /// Initializes the component view controller.
    ///
    /// - Parameter rootViewController: The root view controller to be displayed.
    /// - Parameter cancelButtonHandler: An optional callback for the cancel button.
    public init(rootViewController: UIViewController, cancelButtonHandler: (() -> Void)? = nil) {
        self.cancelButtonHandler = cancelButtonHandler
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
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
        
        // If we're being presented inside a UINavigationController, skip the use of our own navigation controller.
        if parent is UINavigationController {
            display(viewController: rootViewController)
        } else {
            display(viewController: NavigationController(rootViewController: rootViewController))
        }
    }
    
    /// :nodoc:
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        children.first?.view.frame = view.bounds
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
    }
}
