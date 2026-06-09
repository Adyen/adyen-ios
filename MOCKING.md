# Mocking Guide

The project uses [Sourcery](https://github.com/krzysztofzablocki/Sourcery) to auto-generate mock implementations from protocols.

## Running the Generator

Build the `GenerateSourcery` scheme to regenerate mocks:

```bash
xcodebuild -project Adyen.xcodeproj -scheme GenerateSourcery build
```

## Adding a New Mock

Add `// sourcery: AutoMockable` above any protocol (see [`StoredCardInputViewModelProtocol`](AdyenCard/Components/Stored%20Card/StoredCardInputView/StoredCardInputViewModel.swift) for an example).

Generated mocks are output to [`Tests/GeneratedMocks/`](Tests/GeneratedMocks/). Configuration: [`Tools/Sourcery/.sourcery.yml`](Tools/Sourcery/.sourcery.yml).
