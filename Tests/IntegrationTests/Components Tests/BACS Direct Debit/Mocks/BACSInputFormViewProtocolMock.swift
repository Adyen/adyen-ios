//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents

class BACSInputFormViewProtocolMock: BACSInputFormViewProtocol {

    // MARK: - setupNavigationBar

    var setupNavigationBarCallsCount = 0
    var setupNavigationBarCalled: Bool {
        setupNavigationBarCallsCount > 0
    }

    func setupNavigationBar() {
        setupNavigationBarCallsCount += 1
    }

    // MARK: - addItem

    var addItemCallsCount = 0
    var addItemCalled: Bool {
        addItemCallsCount > 0
    }

    func add(item: (some FormItem)?) {
        addItemCallsCount += 1
    }

    // MARK: - displayValidation

    var displayValidationCallsCount = 0
    var displayValidationCalled: Bool {
        displayValidationCallsCount > 0
    }

    func displayValidation() {
        displayValidationCallsCount += 1
    }
}
