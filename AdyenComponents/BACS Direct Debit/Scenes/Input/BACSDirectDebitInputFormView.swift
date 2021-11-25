//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal protocol BACSDirectDebitInputFormViewProtocol {
    func add<T: FormItem>(item: T?)
    func displayValidation()
}

internal class BACSDirectDebitInputFormView: FormViewController, BACSDirectDebitInputFormViewProtocol {

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

    internal func add<T: FormItem>(item: T?) {
        guard let item = item else { return }
        append(item)
    }

    internal func displayValidation() {
        _ = validate()
    }
}

extension BACSDirectDebitInputFormView: ViewControllerDelegate {
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
