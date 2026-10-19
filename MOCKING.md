# Mocking Guide

Mocks in this project are hand-written test doubles. **Do not add new Sourcery-generated mocks** — Sourcery is being removed from the codebase. Write regular mocks, as the majority of existing tests already do.

## Adding a New Mock

Create a class conforming to the protocol, named with the `Mock` suffix, following the call-recording pattern used across the test suite:

```swift
final class PaymentComponentDelegateMock: PaymentComponentDelegate {

    var didSubmitCallsCount = 0
    var didSubmitCalled: Bool {
        didSubmitCallsCount > 0
    }

    var didSubmitReceivedArguments: (data: PaymentComponentData, component: PaymentComponent)?
    var onDidSubmit: ((PaymentComponentData, PaymentComponent) -> Void)?
    func didSubmit(_ data: PaymentComponentData, from component: PaymentComponent) {
        didSubmitCallsCount += 1
        didSubmitReceivedArguments = (data: data, component: component)
        onDidSubmit?(data, component)
    }

    var didFailCallsCount = 0
    var didFailCalled: Bool {
        didFailCallsCount > 0
    }

    var didFailReceivedArguments: (error: Error, component: PaymentComponent)?
    var onDidFail: ((Error, PaymentComponent) -> Void)?
    func didFail(with error: Error, from component: PaymentComponent) {
        didFailCallsCount += 1
        didFailReceivedArguments = (error: error, component: component)
        onDidFail?(error, component)
    }
}
```

Full example: [`PaymentComponentDelegateMock`](Tests/Common/Mocks/PaymentComponentDelegateMock.swift).

### Conventions

For each protocol method:

- `<method>CallsCount` and `<method>Called` to verify invocations
- `<method>ReceivedArguments` to capture arguments for assertions
- `<method>ReturnValue` to stub return values
- an optional `on<Method>` closure to stub behavior or return values dynamically

### Placement

- Reused mocks live in [`Tests/Common/Mocks/`](Tests/Common/Mocks/)
- Feature-specific mocks live next to the tests using them (often in a `Mocks/` folder)

## Legacy Generated Mocks

Mocks in [`Tests/GeneratedMocks/`](Tests/GeneratedMocks/) are Sourcery output scheduled for removal. Do not add protocols to them, regenerate them, or add `// sourcery: AutoMockable` annotations. If a change requires updating a generated mock, replace it with a hand-written mock instead.
