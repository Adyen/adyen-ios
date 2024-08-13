//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockShell: ShellHandling {
    
    var handleExecute: (String) -> String = { _ in
        XCTFail("Unexpectedly called `\(#function)`")
        return ""
    }
    
    @discardableResult
    func execute(_ command: String) -> String {
        handleExecute(command)
    }
}
