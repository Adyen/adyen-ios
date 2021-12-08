//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol BACSDirectDebitInputFormViewProtocol: FormViewProtocol {}

internal class BACSDirectDebitInputFormViewController: FormViewController, BACSDirectDebitInputFormViewProtocol {

    // MARK: - Properties

    internal weak var presenter: BACSDirectDebitInputPresenterProtocol?

    // MARK: - Initializers

    internal init(title: String,
                  styleProvider: FormComponentStyle,
                  localizationParameters: LocalizationParameters? = nil) {
        super.init(style: styleProvider)
        self.title = title
        self.delegate = self
        self.localizationParameters = localizationParameters
    }
}

extension BACSDirectDebitInputFormViewController: ViewControllerDelegate {
    internal func viewDidLoad(viewController: UIViewController) {}

    internal func viewDidAppear(viewController: UIViewController) {}
    
    internal func viewWillAppear(viewController: UIViewController) {
        presenter?.viewWillAppear()
    }
}
