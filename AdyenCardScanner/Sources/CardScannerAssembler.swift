//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AVFoundation
import Foundation
import UIKit

internal protocol CardScannerAssembling {
    func resolveCardScannerViewController(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> CardScannerViewController?
}

internal class CardScannerAssembler: CardScannerAssembling {

    // MARK: - Initializers

    internal let captureDevice: AVCaptureDevice?

    internal init() {
        self.captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        )
    }

    // MARK: - CardScannerAssemblerProtocol

    internal func resolveCardScannerViewController(
        localizationBundle: Bundle,
        completion: @escaping (Result<CardScanDetails, CardScannerError>) -> Void
    ) -> CardScannerViewController? {
        guard let captureDevice else { return nil }

        let expireDateFormatter = ExpirationDateFormatter()
        let cardImageParser = CardImageParser(expirationDateFormatter: expireDateFormatter)

        let captureSessionManager = CaptureSessionManager(captureDevice: captureDevice)
        let viewModel = CardScannerViewModel(
            cardImageParser: cardImageParser,
            captureSessionManager: captureSessionManager,
            localizationBundle: localizationBundle,
            completion: completion
        )

        let view = CardScannerViewController(viewModel: viewModel)
        viewModel.view = view
        return view
    }
}
