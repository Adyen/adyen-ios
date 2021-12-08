//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSConfirmationViewProtocol: FormViewProtocol {}

internal class BACSConfirmationViewController: FormViewController,
    BACSConfirmationViewProtocol {

    // MARK: - Properties

    internal weak var presenter: BACSConfirmationPresenterProtocol?

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

extension BACSConfirmationViewController: ViewControllerDelegate {
    internal func viewDidLoad(viewController: UIViewController) {
        // TODO: - Logic
        presenter?.viewDidLoad()
    }

    internal func viewDidAppear(viewController: UIViewController) {
        // TODO: - Logic
    }

    internal func viewWillAppear(viewController: UIViewController) {
        // TODO: - Logic
    }

}
