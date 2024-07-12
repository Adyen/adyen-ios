//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
import UIKit

protocol CustomComponentAssemblerProtocol {
    func resolveCustomComponentView() -> UIViewController
}

class CustomComponentAssembler: CustomComponentAssemblerProtocol {

    // MARK: - Initializers

    init() { /* Empty initializer */ }

    // MARK: - CustomComponentAssemblerProtocol

    func resolveCustomComponentView() -> UIViewController {
        let apiClient = resolveAPIClient()
        let presenter = CustomComponentPresenter(apiClient: apiClient)
        let view = CustomComponentViewController(presenter: presenter)
        presenter.view = view
        return view
    }

    // MARK: - Private

    private func resolveAPIClient() -> APIClientProtocol {
        ApiClientHelper.generateApiClient()
    }
}
