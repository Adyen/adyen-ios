//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
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
        super.init(style: styleProvider)
        self.title = title
        self.localizationParameters = localizationParameters
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
