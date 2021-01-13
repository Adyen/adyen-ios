//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

final class FormatterMock: Adyen.Formatter {
    
    var handleFormattedValue: ((_ value: String) -> String)?
    func formattedValue(for value: String) -> String {
        return handleFormattedValue?(value) ?? value
    }
    
    var handleSanitizedValue: ((_ value: String) -> String)?
    func sanitizedValue(for value: String) -> String {
        return handleSanitizedValue?(value) ?? value
    }
    
}
