//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import Foundation

class ExpirationDateFormattingMock: ExpirationDateFormatting {

    // MARK: - date(from:)

    var dateCallsCount = 0
    var dateCalled: Bool {
        dateCallsCount > 0
    }

    var dateReceivedString: String?
    var dateReceivedInvocations: [String] = []
    var dateReturnValue: Date?
    var dateClosure: ((String) -> Date?)?

    func date(from string: String) -> Date? {
        dateCallsCount += 1
        dateReceivedString = string
        dateReceivedInvocations.append(string)
        return dateClosure?(string) ?? dateReturnValue
    }
}
