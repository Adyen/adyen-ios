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

    internal weak var presenter: BACSDirectDebitPresenterProtocol?

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

    // MARK: - Private

    @objc
    private func didTapCancelButton() {
        resignFirstResponder()
        presenter?.didCancel()
    }
}

extension BACSDirectDebitInputFormViewController: ViewControllerDelegate {
    func viewDidLoad(viewController: UIViewController) {
        presenter?.viewDidLoad()
    }

    func viewDidAppear(viewController: UIViewController) {
        // TODO: - Complete with logic
    }

    func viewWillAppear(viewController: UIViewController) {
        // TODO: - Complete with logic
        // 1. Fill form fields (reset when view disappears)
    }
}
