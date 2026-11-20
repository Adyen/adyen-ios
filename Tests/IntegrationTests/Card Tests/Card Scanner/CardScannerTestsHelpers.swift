//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenCardScanner)
    @testable import AdyenCard
    @testable import AdyenCardScanner

    @MainActor
    internal class CardScannerProviderSpy: @MainActor CardScannerProviding {
        private var completion: (@MainActor @Sendable (Result<CardScannerCardDetails, Error>) -> Void)?

        func createCardScanner(
            completion: @escaping @MainActor @Sendable (Result<CardScannerCardDetails, Error>) -> Void
        ) -> UIViewController? {
            self.completion = completion
            return UIViewController()
        }

        func onScanComplete(result: Result<CardScannerCardDetails, Error>) {
            self.completion?(result)
        }
    }
#endif
