//
//  AnyRetryAPIClientMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/12/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation
@testable import Adyen

enum DummyError: Error {
    case dummy
}

final class APIClientMock: APIClientProtocol {

    var mockedResults: [Result<Response, Error>] = []

    private(set) var counter: Int = 0

    func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R : Request {
        counter += 1

        let nextResult = mockedResults.removeFirst()

        switch nextResult {
        case let .success(response):
            guard let response = response as? R.ResponseType else { return }
            completionHandler(.success(response))
        case let .failure(error):
            completionHandler(.failure(error))
        }
    }

}
