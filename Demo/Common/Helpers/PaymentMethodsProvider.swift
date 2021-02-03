//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal protocol PaymentMethodsProvider {

    typealias Callback = (Result<PaymentMethods, Error>) -> Void

    func request(callback: @escaping Callback)

}

final class NetworkPaymentMethodsProvider: PaymentMethodsProvider, HasAPIClient {

    internal func request(callback: @escaping Callback) {
        let request = PaymentMethodsRequest()
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                callback(.success(response.paymentMethods))
            case let .failure(error):
                callback(.failure(error))
            }
        }
    }

}

final class LocalPaymentMethodProvider: PaymentMethodsProvider {

    // swiftlint:disable:enable force_try
    func request(callback: @escaping Callback) {
        let data = try! Data(contentsOf: Bundle.main.url(forResource: "payment_methods_response", withExtension: "json")!)
        let response = try! JSONDecoder().decode(PaymentMethodsResponse.self, from: data)
        callback(.success(response.paymentMethods))
    }
    // swiftlint:disable:diable force_try

}
