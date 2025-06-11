//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal class DropInRootViewController: UINavigationController {

    // MARK: - Properties

    private let viewModel: DropInRootViewModelProtocol

    // MARK: - Initializers

    internal init(
        rootViewController: UIViewController,
        viewModel: DropInRootViewModelProtocol
    ) {
        self.viewModel = viewModel
        super.init(rootViewController: rootViewController)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
