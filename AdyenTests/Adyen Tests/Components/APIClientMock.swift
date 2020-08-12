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

    var mockedResponse: Response?

    var mockedError: Error?

    private(set) var counter: Int = 0

    func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R : Request {
        counter += 1
        if let response = mockedResponse as? R.ResponseType {
            completionHandler(Result.success(response))
        } else if let error = mockedError {
            completionHandler(Result.failure(error))
        }
    }

}
