//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

protocol BACSConfirmationViewProtocol: FormViewProtocol {
    func setUserInteraction(enabled: Bool)
}

class BACSConfirmationViewController: FormViewController, BACSConfirmationViewProtocol {

    // MARK: - Properties

    weak var presenter: BACSConfirmationPresenterProtocol?

    // MARK: - Initializers

    init(title: String,
         styleProvider: FormComponentStyle,
         localizationParameters: LocalizationParameters? = nil) {
        super.init(
            style: styleProvider,
            localizationParameters: localizationParameters
        )
        self.title = title
    }

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    // MARK: - BACSConfirmationViewProtocol

    func setUserInteraction(enabled: Bool) {
        view.isUserInteractionEnabled = enabled
    }
}
