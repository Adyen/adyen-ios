//
//  AnyRetryAPIClientMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/12/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation
@testable import Adyen

typealias MockedResult = Result<Response, Error>

enum Dummy: Error {
    case dummyError

    /// This is not a real public key, this is just a random string with the right pattern.
    internal static var dummyPublicKey = "1B2F|B22CD14EF451C993318F5BDE9DA1AAEE32269D1D13590DC23761113F0E01D7D0A19910BA1DDE9348C29DCE4ED32AB121ABF6C9AF771DAB547BD4261A50FCE3686747D581455A31C166CCD84E0B3FAB2B23F9E8CB69864C520C60247A5E64C669D0719A31132AF3CEE94DB56AB2840B967FCFC65DFAD092121AE8C6435EAB95D1"
}

final class APIClientMock: APIClientProtocol {

    var mockedResults: [MockedResult] = []
    var onExecute: (()->Void)?

    private(set) var counter: Int = 0

    func perform<R>(_ request: R, completionHandler: @escaping (Result<R.ResponseType, Error>) -> Void) where R : Request {
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
