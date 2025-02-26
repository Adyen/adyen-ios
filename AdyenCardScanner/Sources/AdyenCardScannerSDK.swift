//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public class AdyenCardScannerSDK {

    public static func createCardScanner(
        completion: @escaping (Result<CreditCard, CardScannerError>) -> Void
    ) throws -> UIViewController {
        let assembler = CardScannerAssembler()
        let cardScannerViewController = try assembler.resolveCardScannerViewController(completion: completion)
        return cardScannerViewController
    }
}
