//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
@_spi(AdyenInternal) import Adyen

struct NativeRedirectResultRequest: Request {
    typealias ResponseType = RedirectDetails

    typealias ErrorResponseType = APIError

    let path: String = "checkoutshopper/v1/nativeRedirect/redirectResult"

    var counter: UInt = 0

    let headers: [String: String] = [:]

    let queryParameters: [URLQueryItem] = []

    let method: HTTPMethod = .post

    let redirectData: String?

    let returnQueryString: String

    init(redirectData: String?, returnQueryString: String) {
        self.redirectData = redirectData
        self.returnQueryString = returnQueryString
    }

    private enum CodingKeys: String, CodingKey {
        case redirectData
        case returnQueryString
    }
}

extension RedirectDetails: Response {}
