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
        viewModel.items.forEach { append($0) }
        bindState()
    }

    // MARK: - Private

    private func bindState() {
        viewModel.$state.sink { [weak self] state in
            switch state {
            case .idle:
                self?.setLoading(false)
            case .invalid:
                self?.setLoading(false)
                _ = self?.validate()
            case .submitting:
                self?.setLoading(true)
            }
        }.store(in: &cancellables)
    }

    private func setLoading(_ isLoading: Bool) {
        viewModel.submitButtonItem?.showsActivityIndicator = isLoading
        view.isUserInteractionEnabled = !isLoading
    }
}
