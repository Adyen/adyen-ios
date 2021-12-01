//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class ComponentNavigationController: UINavigationController {

    // MARK: - Properties

    private let cancelHandler: ((Bool) -> Void)?

    // MARK: - Initializers

    internal init(rootViewController: UIViewController, cancelHandler: ((Bool) -> Void)? = nil) {
        self.cancelHandler = cancelHandler
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Private

    override internal func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        cancelHandler?(false)
    }
}
