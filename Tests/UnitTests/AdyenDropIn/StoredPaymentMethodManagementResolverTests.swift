//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing

@MainActor
struct StoredPaymentMethodManagementResolverTests {

    @Test
    func capability_whenRemovalOperationIsInjected_shouldUseOperation() async throws {
        // Given
        let paymentMethod = try storedPaymentMethod()
        let spy = StoredPaymentMethodRemovalHandlerSpy()
        let capability = StoredPaymentMethodManagementCapability { storedPaymentMethod in
            spy.remove(storedPaymentMethod)
        }

        // When
        try await capability.remove(paymentMethod)

        // Then
        #expect(spy.receivedStoredPaymentMethodIdentifier == paymentMethod.identifier)
    }

    @Test
    func managementCapability_whenResolverIsAvailable_shouldBeExposedByDropInComponent() {
        // Given
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        let delegate = StoredPaymentMethodsDelegateMock(completionResults: [true])
        dropInComponent.storedPaymentMethodsDelegate = delegate

        // Then
        #expect(dropInComponent.storedPaymentMethodManagementCapability != nil)
    }

    @Test
    func capability_whenAdvancedManagementIsEnabled_shouldPassStoredPaymentMethod() async throws {
        // Given
        let paymentMethod = try storedPaymentMethod()
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        let delegate = StoredPaymentMethodsDelegateMock(completionResults: [true])
        dropInComponent.storedPaymentMethodsDelegate = delegate
        let sut = StoredPaymentMethodManagementResolver(dropInComponent: dropInComponent)
        let capability = try #require(sut.capability)

        // When
        try await capability.remove(paymentMethod)

        // Then
        #expect(delegate.receivedStoredPaymentMethodIdentifier == paymentMethod.identifier)
    }

    @Test
    func capability_whenAdvancedManagementIsDisabled_shouldBeNil() {
        // Given
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: false)
        dropInComponent.storedPaymentMethodsDelegate = StoredPaymentMethodsDelegateMock(completionResults: [true])
        let sut = StoredPaymentMethodManagementResolver(dropInComponent: dropInComponent)

        // Then
        #expect(sut.capability == nil)
    }

    @Test
    func capability_whenSessionManagementIsEnabled_shouldUseSessionRemovalPath() async throws {
        // Given
        let paymentMethod = try storedPaymentMethod()
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: false)
        let delegate = SessionStoredPaymentMethodsDelegateMock(
            showRemovePaymentMethodButton: true,
            completionResults: [true]
        )
        dropInComponent.storedPaymentMethodsDelegate = delegate
        let sut = StoredPaymentMethodManagementResolver(dropInComponent: dropInComponent)
        let capability = try #require(sut.capability)

        // When
        try await capability.remove(paymentMethod)

        // Then
        #expect(delegate.receivedStoredPaymentMethodIdentifier == paymentMethod.identifier)
        #expect(delegate.receivedDropInComponent === dropInComponent)
    }

    @Test
    func capability_whenSessionManagementIsDisabled_shouldBeNil() {
        // Given
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        let delegate = SessionStoredPaymentMethodsDelegateMock(
            showRemovePaymentMethodButton: false,
            completionResults: [true]
        )
        dropInComponent.storedPaymentMethodsDelegate = delegate
        let sut = StoredPaymentMethodManagementResolver(dropInComponent: dropInComponent)

        // Then
        #expect(sut.capability == nil)
    }

    @Test
    func capability_whenDelegateIsUnavailable_shouldBeNil() {
        // Given
        let sut = StoredPaymentMethodManagementResolver(
            dropInComponent: dropInComponent(allowsDisablingStoredPaymentMethods: true)
        )

        // Then
        #expect(sut.capability == nil)
    }

    @Test
    func remove_whenDelegateFails_shouldThrowUnsuccessfulError() async throws {
        // Given
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        let delegate = StoredPaymentMethodsDelegateMock(completionResults: [false])
        dropInComponent.storedPaymentMethodsDelegate = delegate
        let sut = StoredPaymentMethodManagementResolver(dropInComponent: dropInComponent)
        let capability = try #require(sut.capability)

        // When
        await #expect(throws: StoredPaymentMethodRemovalError.unsuccessful) {
            try await capability.remove(storedPaymentMethod())
        }
    }

    @Test
    func remove_whenDelegateCallsCompletionTwice_shouldResolveOnlyOnce() async throws {
        // Given
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        let delegate = StoredPaymentMethodsDelegateMock(completionResults: [true, false])
        dropInComponent.storedPaymentMethodsDelegate = delegate
        let sut = StoredPaymentMethodManagementResolver(dropInComponent: dropInComponent)
        let capability = try #require(sut.capability)

        // When
        try await capability.remove(storedPaymentMethod())

        // Then
        #expect(delegate.completionCallCount == 2)
    }

    @Test
    func remove_whenResolverIsDeallocated_shouldThrowUnavailableError() async throws {
        // Given
        let dropInComponent = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        let delegate = StoredPaymentMethodsDelegateMock(completionResults: [true])
        dropInComponent.storedPaymentMethodsDelegate = delegate
        var resolver: StoredPaymentMethodManagementResolver? = .init(dropInComponent: dropInComponent)
        let capability = try #require(resolver?.capability)
        resolver = nil

        // Then
        await #expect(throws: StoredPaymentMethodRemovalError.unavailable) {
            try await capability.remove(storedPaymentMethod())
        }
    }

    @Test
    func remove_whenDropInIsDeallocated_shouldThrowUnavailableError() async throws {
        // Given
        let delegate = StoredPaymentMethodsDelegateMock(completionResults: [true])
        var dropInComponent: DropInComponent? = dropInComponent(allowsDisablingStoredPaymentMethods: true)
        dropInComponent?.storedPaymentMethodsDelegate = delegate
        let resolver = try #require(dropInComponent.map(StoredPaymentMethodManagementResolver.init))
        let capability = try #require(resolver.capability)
        dropInComponent = nil

        // Then
        await #expect(throws: StoredPaymentMethodRemovalError.unavailable) {
            try await capability.remove(storedPaymentMethod())
        }
    }

    private func dropInComponent(allowsDisablingStoredPaymentMethods: Bool) -> DropInComponent {
        let configuration = DropInComponent.Configuration()
        configuration.paymentMethodsList.allowDisablingStoredPaymentMethods = allowsDisablingStoredPaymentMethods

        return DropInComponent(
            paymentMethods: PaymentMethods(regular: [], stored: []),
            context: Dummy.context,
            configuration: configuration
        )
    }

    private func storedPaymentMethod() throws -> StoredCardPaymentMethod {
        try AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
    }
}

@MainActor
private final class StoredPaymentMethodsDelegateMock: StoredPaymentMethodsDelegate {

    private let completionResults: [Bool]
    private(set) var completionCallCount = 0
    private(set) var receivedStoredPaymentMethodIdentifier: String?

    init(completionResults: [Bool]) {
        self.completionResults = completionResults
    }

    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>) {
        receivedStoredPaymentMethodIdentifier = storedPaymentMethod.identifier

        for result in completionResults {
            completionCallCount += 1
            completion(result)
        }
    }
}

@MainActor
private final class SessionStoredPaymentMethodsDelegateMock: SessionStoredPaymentMethodsDelegate {

    let showRemovePaymentMethodButton: Bool

    private let completionResults: [Bool]
    private(set) var receivedStoredPaymentMethodIdentifier: String?
    private(set) weak var receivedDropInComponent: AnyObject?

    init(showRemovePaymentMethodButton: Bool, completionResults: [Bool]) {
        self.showRemovePaymentMethodButton = showRemovePaymentMethodButton
        self.completionResults = completionResults
    }

    func disable(
        storedPaymentMethod: StoredPaymentMethod,
        dropInComponent: AnyDropInComponent,
        completion: @escaping Completion<Bool>
    ) {
        receivedStoredPaymentMethodIdentifier = storedPaymentMethod.identifier
        receivedDropInComponent = dropInComponent as AnyObject

        for result in completionResults {
            completion(result)
        }
    }

    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>) {
        Issue.record("The Session removal path should be used.")
    }
}

@MainActor
private final class StoredPaymentMethodRemovalHandlerSpy {

    private(set) var receivedStoredPaymentMethodIdentifier: String?

    func remove(_ storedPaymentMethod: StoredPaymentMethod) {
        receivedStoredPaymentMethodIdentifier = storedPaymentMethod.identifier
    }
}
