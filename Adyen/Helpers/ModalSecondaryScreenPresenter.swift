//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Presents secondary screens as modal sheets with a close button.
///
/// Used by standalone components, which route their secondary screens themselves.
/// Secondary screens are content only, so this presenter adds the navigation bar and the close button.
@MainActor
package final class ModalSecondaryScreenPresenter: ViewControllerPresenter {

    /// Looked up when presenting, not when created,
    /// so a component can create this presenter while its own screen is still being built.
    private let source: () -> UIViewController?

    package init(source: @escaping () -> UIViewController?) {
        self.source = source
    }

    package convenience init(source: UIViewController) {
        self.init { [weak source] in source }
    }

    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        let navigationController = ClosableNavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: navigationController,
            action: #selector(ClosableNavigationController.close)
        )
        source()?.adyen.topPresenter.present(navigationController, animated: animated)
    }

    package func dismissViewController(_ viewController: UIViewController, animated: Bool) {
        guard let navigationController = viewController.navigationController as? ClosableNavigationController,
              navigationController.viewControllers.first === viewController,
              !navigationController.isBeingDismissed,
              let presentingViewController = navigationController.presentingViewController else { return }
        presentingViewController.dismiss(animated: animated)
    }
}

/// The navigation bar around a modal secondary screen. It owns the action of the screen's close button.
private final class ClosableNavigationController: UINavigationController {
    @objc func close() {
        dismiss(animated: true)
    }
}
