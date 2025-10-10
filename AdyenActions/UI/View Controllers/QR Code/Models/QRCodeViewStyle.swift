//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal struct QRCodeViewStyle {
    internal let copyCodeButton: ButtonStyle
    internal let saveAsImageButton: ButtonStyle
    internal let instructionLabel: TextStyle
    internal let amountToPayLabel: TextStyle
    internal let progressView: ProgressViewStyle
    internal let expirationLabel: TextStyle
    internal let logoCornerRounding: CornerRounding
    internal let backgroundColor: UIColor
}
