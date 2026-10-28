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

    private weak var source: UIViewController?

    /// The navigation controllers presented so far, oldest first.
    private var presentedScreens: [WeakNavigationController] = []

    /// - Parameter source: The screen the secondary screens are presented from.
    package init(source: UIViewController) {
        self.source = source
    }

    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        let navigationController = SecondaryScreenNavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: navigationController,
            action: #selector(SecondaryScreenNavigationController.close)
        )
        presentedScreens.append(WeakNavigationController(value: navigationController))
        source?.adyen.topPresenter.present(navigationController, animated: animated)
    }

    /// Closes the newest secondary screen only,
    /// so a picker opened from the address form keeps the form open.
    /// Does nothing once every secondary screen is closed.
    package func dismissViewController(animated: Bool) {
        presentedScreens.removeAll { $0.value?.presentingViewController == nil }
        presentedScreens.popLast()?.value?.dismiss(animated: animated)
    }
}

/// The navigation bar around a modal secondary screen. It owns the close action of its close button.
private final class SecondaryScreenNavigationController: UINavigationController {

    @objc func close() {
        dismiss(animated: true)
    }
}

private struct WeakNavigationController {
    weak var value: UINavigationController?
}
