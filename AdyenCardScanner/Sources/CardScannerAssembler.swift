//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AVFoundation
import Foundation
import UIKit

protocol CardScannerAssembling {
    func resolveCardScannerViewController(
        completion: @escaping (Result<CreditCard, CardScannerError>) -> Void
    ) throws -> UIViewController
}

class CardScannerAssembler: CardScannerAssembling {

    // MARK: - Initializers

    init() { /* Empty initializer */ }

    // MARK: - CardScannerAssemblerProtocol

    func resolveCardScannerViewController(
        completion: @escaping (Result<CreditCard, CardScannerError>) -> Void
    ) throws -> UIViewController {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CardScannerError(kind: .cameraSetup)
        }

        let expireDateFormatter = ExpirationDateFormatter()
        let cardImageParser = CardImageParser(expirationDateFormatter: expireDateFormatter)

        let captureSessionManager = CaptureSessionManager(captureDevice: captureDevice)
        let viewModel = CardScannerViewModel(
            cardImageParser: cardImageParser, captureSessionManager: captureSessionManager,
            completion: completion
        )

        return CardScannerViewController(viewModel: viewModel)
    }
}
