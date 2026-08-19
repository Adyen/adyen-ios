//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn

@MainActor
// swiftlint:disable:next type_name
final class StoredPaymentMethodManagementListenerMock: StoredPaymentMethodManagementListener {

    private(set) var removedPaymentMethods: [any StoredPaymentMethod] = []
    private(set) var paymentOptionsRequestCount = 0
    private(set) var dismissalCount = 0

    func didRemoveStoredPaymentMethod(_ paymentMethod: any StoredPaymentMethod) {
        removedPaymentMethods.append(paymentMethod)
    }

    func didRequestPaymentOptions() {
        paymentOptionsRequestCount += 1
    }

    func didDismissStoredPaymentMethodManagement() {
        dismissalCount += 1
    }
}

@MainActor
// swiftlint:disable:next type_name
final class StoredPaymentMethodManagementRoutingMock: StoredPaymentMethodManagementRouting {

    private(set) var removedPaymentMethods: [any StoredPaymentMethod] = []
    private(set) var paymentOptionsRequestCount = 0

    func didRemove(paymentMethod: any StoredPaymentMethod) {
        removedPaymentMethods.append(paymentMethod)
    }

    func didRequestPaymentOptions() {
        paymentOptionsRequestCount += 1
    }
}
