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

    private let innerController: UIViewController

    internal weak var delegate: ViewControllerDelegate?

    // MARK: - Initializing
    
    /// Initializes the component view controller.
    ///
    /// - Parameter rootViewController: The root view controller to be displayed.
    /// - Parameter cancelButtonHandler: An optional callback for the cancel button.
    internal init(
        rootViewController: UIViewController,
        cancelButtonHandler: ((Bool) -> Void)? = nil
    ) {
        self.innerController = rootViewController
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
    }

    private func addChildViewController() {
        innerController.willMove(toParent: self)
        addChild(innerController)
        view.addSubview(innerController.view)
        innerController.didMove(toParent: self)
        arrangeConstraints()
    }

    // MARK: - Private

    private func didCancel() {
        guard let cancelHandler = cancelButtonHandler else { return }
        
        innerController.resignFirstResponder()
        cancelHandler(isRoot)
    }

    private func arrangeConstraints() {
        innerController.view.adyen.anchor(inside: view)
    }
}
