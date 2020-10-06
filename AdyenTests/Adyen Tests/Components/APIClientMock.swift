//
//  AnyRetryAPIClientMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/12/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
import Foundation

typealias MockedResult = Result<Response, Error>

enum Dummy: Error {
    case dummyError

    /// This is not a real public key, this is just a random string with the right pattern.
    internal static var dummyPublicKey = "9E1CB|\(RandomStringGenerator.generateRandomHexadecimalString(length: 512))"
}

final class APIClientMock: APIClientProtocol {

    var mockedResults: [MockedResult] = []
    var onExecute: (() -> Void)?

    private(set) var counter: Int = 0

    func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R: Request {
        counter += 1
        DispatchQueue.main.async {
            self.onExecute?()
            let nextResult = self.mockedResults.removeFirst()
            switch nextResult {
            case let .success(response):
                guard let response = response as? R.ResponseType else { return }
                completionHandler(.success(response))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

}
