//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

protocol BACSInputFormViewProtocol: FormViewProtocol {}

class BACSInputFormViewController: FormViewController, BACSInputFormViewProtocol {

    // MARK: - Properties

    weak var presenter: BACSInputPresenterProtocol?

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }
}
