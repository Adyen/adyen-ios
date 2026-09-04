//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import XCTest

@MainActor
final class DropInViewModelTests: XCTestCase {

    func test_root_withNoPaymentMethods_shouldShowPaymentMethodList() {
        let (sut, _) = makeSUT()

        guard case .paymentMethodList = sut.root else {
            return XCTFail("Expected the payment method list")
        }
    }

    func test_root_withStoredPaymentMethod_shouldShowPreselectedPaymentMethod() throws {
        let storedPaymentMethod = try makeStoredPaymentMethod()
        let (sut, _) = makeSUT(storedPaymentMethods: [storedPaymentMethod])

        guard case let .preselected(component) = sut.root else {
            return XCTFail("Expected the preselected payment method")
        }
        XCTAssertEqual((component.paymentMethod as? any StoredPaymentMethod)?.identifier, storedPaymentMethod.identifier)
    }

    func test_root_withPreselectionDisabled_shouldShowPaymentMethodList() throws {
        let storedPaymentMethod = try makeStoredPaymentMethod()
        let configuration = DropInConfiguration().startWithLastStoredPaymentMethod(false)
        let (sut, _) = makeSUT(
            storedPaymentMethods: [storedPaymentMethod],
            configuration: configuration
        )

        guard case .paymentMethodList = sut.root else {
            return XCTFail("Expected the payment method list")
        }
    }

    func test_root_withSingleRegularPaymentMethod_shouldSkipPaymentMethodList() throws {
        let paymentMethod = try AdyenCoder.decode(creditCardDictionary) as CardPaymentMethod
        let (sut, _) = makeSUT(regularPaymentMethods: [paymentMethod])

        guard case let .component(component) = sut.root else {
            return XCTFail("Expected the single payment component")
        }
        XCTAssertEqual(component.paymentMethod.type, .scheme)
        XCTAssertTrue(DropInConfiguration().allowsSkippingPaymentList)
    }

    func test_storedPaymentMethodFlags_shouldRemainIndependentForEveryCombination() throws {
        let storedPaymentMethod = try makeStoredPaymentMethod()

        for hideStoredPaymentMethods in [false, true] {
            for startWithLastStoredPaymentMethod in [false, true] {
                let configuration = DropInConfiguration()
                    .hideStoredPaymentMethods(hideStoredPaymentMethods)
                    .startWithLastStoredPaymentMethod(startWithLastStoredPaymentMethod)
                let (sut, componentManager) = makeSUT(
                    storedPaymentMethods: [storedPaymentMethod],
                    configuration: configuration
                )

                XCTAssertEqual(componentManager.storedComponents.count, 1)
                XCTAssertEqual(
                    componentManager.sections.contains { $0.kind == .stored },
                    !hideStoredPaymentMethods
                )

                if startWithLastStoredPaymentMethod {
                    guard case .preselected = sut.root else {
                        return XCTFail("Expected preselection for hideStoredPaymentMethods=\(hideStoredPaymentMethods)")
                    }
                } else {
                    guard case .paymentMethodList = sut.root else {
                        return XCTFail("Expected the list for hideStoredPaymentMethods=\(hideStoredPaymentMethods)")
                    }
                }
            }
        }
    }

    private func makeSUT(
        regularPaymentMethods: [PaymentMethod] = [],
        storedPaymentMethods: [any StoredPaymentMethod] = [],
        configuration: DropInConfiguration = .init()
    ) -> (DropInViewModel, ComponentManager) {
        let paymentMethods = PaymentMethods(
            regular: regularPaymentMethods,
            stored: storedPaymentMethods
        )
        let componentManager = ComponentManager(
            paymentMethods: paymentMethods,
            context: Dummy.context,
            configuration: configuration,
            order: nil,
            presentationDelegate: nil
        )
        let sut = DropInViewModel(
            title: "Drop-in",
            componentManager: componentManager,
            apiClient: APIClientMock(),
            paymentMethods: paymentMethods,
            context: Dummy.context,
            configuration: configuration
        )
        return (sut, componentManager)
    }

    private func makeStoredPaymentMethod() throws -> StoredCardPaymentMethod {
        try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
    }
}
