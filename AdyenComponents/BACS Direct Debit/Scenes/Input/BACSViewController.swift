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
import UIKit

internal protocol BACSView: FormViewProtocol {}

internal class BACSViewController: FormViewController, BACSView {

    // MARK: - Properties

    internal weak var viewModel: BACSViewModelProtocol?

    // MARK: - Initializers

    internal init(
        title: String,
        scrollEnabled: Bool,
        styleProvider: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil
    ) {
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
        viewModel?.viewDidLoad()
    }
}
