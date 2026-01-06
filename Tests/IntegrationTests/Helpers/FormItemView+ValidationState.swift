//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit

extension FormValidatableValueItemView {

    var isShowingValidationError: Bool {
        footerLabel.textColor == theme.colors.destructive
    }

    var isShowingHint: Bool {
        footerLabel.textColor == theme.colors.textSecondary
    }
}
