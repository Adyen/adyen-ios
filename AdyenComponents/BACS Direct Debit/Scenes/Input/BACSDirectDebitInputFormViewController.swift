//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal protocol BACSDirectDebitInputFormViewProtocol: FormViewProtocol {
    func setupNavigationBar()
}

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

    // MARK: - BACSDirectDebitInputFormViewProtocol

    internal func setupNavigationBar() {
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancelButton))
    }

    @objc
    internal func didTapCancelButton() {
        resignFirstResponder()
        presenter?.didCancel()
    }
}

extension BACSDirectDebitInputFormViewController: ViewControllerDelegate {
    internal func viewDidLoad(viewController: UIViewController) {
        presenter?.viewDidLoad()
    }

    internal func viewDidAppear(viewController: UIViewController) {}
    
    internal func viewWillAppear(viewController: UIViewController) {
        // TODO: - Complete with logic
        // 1. Fill form fields (being resetted when view disappears)
    }
}
