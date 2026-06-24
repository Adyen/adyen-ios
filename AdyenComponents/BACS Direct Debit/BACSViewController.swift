//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif
import Combine
import UIKit

internal final class BACSViewController: FormViewController {

    // MARK: - Properties

    private let viewModel: BACSViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers

    internal init(
        title: String,
        viewModel: BACSViewModel
    ) {
        self.viewModel = viewModel
        super.init(
            scrollEnabled: viewModel.configuration.showsSubmitButton,
            style: viewModel.configuration.style,
            localizationParameters: viewModel.configuration.localizationParameters
        )
        self.title = title
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        bindValidation()
        viewModel.items.forEach { append($0) }
    }

    // MARK: - Private

    private func bindValidation() {
        viewModel.$shouldShowValidation.sink { [weak self] shouldShowValidation in
            if shouldShowValidation { self?.showValidation() }
        }.store(in: &cancellables)
    }
}
