//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

protocol ComponentContainerAssemblerProtocol {
    func resolveContainerView(for component: PresentableComponent) -> UIViewController
}

internal struct ComponentContainerAssembler: ComponentContainerAssemblerProtocol {

    // MARK: - ComponentContainerAssemblerProtocol

    func resolveContainerView(for component: PresentableComponent) -> UIViewController {
        let viewModel = ComponentContainerViewModel(
            component: component,
            isRoot: false,
            cancelHandler: nil
        )
        let view = ComponentContainerViewController(viewModel: viewModel)
        return view
    }
}
