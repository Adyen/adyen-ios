//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenCardScanner)
    @testable import AdyenCard
    @testable import AdyenCardScanner

    internal class CardScannerProviderSpy: CardScannerProviding {
        private var completion: ((Result<AdyenCardScanner.CardScanDetails, Error>) -> Void)? = nil

        func createCardScanner(
            completion: @escaping (Result<CardScanDetails, Error>) -> Void
        ) -> UIViewController? {
            self.completion = completion
            return UIViewController()
        }

        func onScanComplete(result: Result<CardScanDetails, Error>) {
            self.completion?(result)
        }
    }
#endif
