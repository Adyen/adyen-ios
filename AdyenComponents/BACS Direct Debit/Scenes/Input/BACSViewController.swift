//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
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
        scrollEnabled: Bool,
        styleProvider: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil,
        viewModel: BACSViewModel
    ) {
        self.viewModel = viewModel
        super.init(
            scrollEnabled: scrollEnabled,
            style: styleProvider,
            localizationParameters: localizationParameters
        )
        self.title = title
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        bindItems()
        bindValidation()
        viewModel.viewDidLoad()
    }

    // MARK: - Private

    private func bindItems() {
        viewModel.$items.sink { items in
            items.forEach { self.add(item: $0) }
        }.store(in: &cancellables)
    }

    private func bindValidation() {
        viewModel.$shouldShowValidation.sink { shouldShowValidation in
            if shouldShowValidation { self.showValidation() }
        }.store(in: &cancellables)
    }
}
