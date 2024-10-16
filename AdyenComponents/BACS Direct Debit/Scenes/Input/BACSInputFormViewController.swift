//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol BACSInputFormViewProtocol: FormViewProtocol {}

internal class BACSInputFormViewController: FormViewController, BACSInputFormViewProtocol {

    // MARK: - Properties

    internal weak var presenter: BACSInputPresenterProtocol?

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
        presenter?.viewDidLoad()
    }

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }
}
