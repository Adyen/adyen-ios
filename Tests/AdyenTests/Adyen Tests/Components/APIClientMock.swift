//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

typealias MockedResult = Result<Response, Error>

enum Dummy: Error {
    case dummyError

    /// This is not a real public key, this is just a random string with the right pattern.
    internal static let dummyPublicKey = "9E1CB|B2BCED4E13103C5983A9B09D63DE84ACC0183D40D0E187DAE2A4390BA63BBFF209FF0C122044B826697C71391E5D5C1449F9C248E47DBB5BEEBCD72D4167F46CD6BBCEBB4E53DB440A86F4C00E155DF4813ABE04D019D6D85BE34044D585A6EE4CF527171EBCB985DA7403AAA762F7358093575A529251DD4D9009471269AC21DD311A29EAD64B1AE809E1F0C74486787FCBBBEBBB2F3573DF6F011566982A49EA96E959215BA6584B61A0CEDD3322AE9D67EE954CA8644851894B85C971982467F1DD0054508DCF3AE74ABB8E6F54DBF2A8ABB6B3CCBB0BD5637DA93200891918D65F9C4D399AABDA94F7CE8125C9B35DE9398DF51CC11E385F951C0B4D8EBD"

    internal static let dummyClientKey = "local_NBSWY3DPEB2GQZLSMUQCAOZJ"
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
