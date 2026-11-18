//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenEncryption
import Foundation
import Testing

final class JSONWebEncryptionGeneratorMock: AnyJSONWebEncryptionGenerator {

    var generateCallsCount = 0
    var generateCalled: Bool {
        generateCallsCount > 0
    }

    var generateReceivedArguments: (payload: Data, publicRSAKey: SecKey, header: JSONWebEncryption.Header)?
    var onGenerate: ((Data, SecKey, JSONWebEncryption.Header) throws -> JSONWebEncryption)?
    func generate(withPayload: Data, publicRSAKey: SecKey, header: JSONWebEncryption.Header) throws -> JSONWebEncryption {
        generateCallsCount += 1
        generateReceivedArguments = (payload: withPayload, publicRSAKey: publicRSAKey, header: header)
        guard let onGenerate else {
            Issue.record("onGenerate is not set")
            throw Dummy.error
        }
        return try onGenerate(withPayload, publicRSAKey, header)
    }
}
