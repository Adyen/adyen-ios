# Mocking Guide

This file provides guidance for generating and using mocks in the Adyen iOS SDK.

## Generating Mocks with Sourcery

The project uses [Sourcery](https://github.com/krzysztofzablocki/Sourcery) to auto-generate mock implementations from protocols. Generated mocks are output to `Tests/GeneratedMocks/`.

### Running the Generator

Build the `GenerateSourcery` scheme to regenerate mocks:

```bash
xcodebuild -project Adyen.xcodeproj -scheme GenerateSourcery build
```

### Marking Protocols as AutoMockable

Add the `// sourcery: AutoMockable` annotation above any protocol to generate a mock:

```swift
// sourcery: AutoMockable
protocol MyProtocol {
    func doSomething()
}
```

After running the generator, a `MyProtocolMock` class will be created in `Tests/GeneratedMocks/`.

### Generated Mock Features

Each generated mock includes:
- **Call tracking**: `<methodName>CallsCount`, `<methodName>Called`
- **Argument capture**: `<methodName>ReceivedArguments`, `<methodName>ReceivedInvocations`
- **Return value stubbing**: `<methodName>ReturnValue`
- **Closure injection**: `<methodName>Closure` for custom behavior
- **Error stubbing**: `<methodName>ThrowableError` for throwing methods

### Example Usage

```swift
// Given a protocol:
// sourcery: AutoMockable
protocol PaymentHandler {
    func process(payment: Payment) throws -> Result
}

// The generated mock can be used as:
let mock = PaymentHandlerMock()
mock.processPaymentReturnValue = .success

let result = try sut.handle(with: mock)

XCTAssertTrue(mock.processPaymentCalled)
XCTAssertEqual(mock.processPaymentReceivedPayment?.amount, expectedAmount)
```

### Configuration

Sourcery configuration is located at `Tools/Sourcery/.sourcery.yml`. The template (`AutoMockable.stencil`) automatically adds `@testable import` for `Adyen` and `AdyenDropIn` modules.
