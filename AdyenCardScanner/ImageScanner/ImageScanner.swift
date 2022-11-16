//
//  ImageScanner.swift
//  AdyenCardScanner
//
//  Created by Mohamed Eldoheiri on 16/11/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
@_spi(AdyenInternal) import Adyen
import Vision

internal protocol ImageScanner {
    var onDetect: ((DetectedCard?) -> Void) { get set }
    func scan(image: CGImage)
}

@available(iOS 13.0, *)
internal struct AppleImageScanner: ImageScanner {
    
    internal enum Error: Swift.Error {
        case nothingFound
    }

    
    private static let scanners: [TextScanner] = [CardNumberScanner()]
    
    var onDetect: ((DetectedCard?) -> Void)
    
    internal func scan(image: CGImage) {
        let textRecognizer = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                return
            }
            let card = try? handle(request: request)
            guard let card = card, card.isEmpty == false else { return }
            onDetect(card)
        }
        
        textRecognizer.recognitionLevel = .accurate
        textRecognizer.usesLanguageCorrection = false
        
        let requestHandler = VNImageRequestHandler(cgImage: image,
                                                   options: [:])
        do {
            try requestHandler.perform([textRecognizer])
        } catch {
            print(error)
        }
    }
    private func handle(request: VNRequest) throws -> DetectedCard {
        guard let results = request.results as? [VNRecognizedTextObservation] else { throw Error.nothingFound  }

        return results.compactMap({ (result: VNRecognizedTextObservation) -> VNRecognizedText? in
            guard let candidate = result.topCandidates(1).first, candidate.confidence > 0.5 else { return nil }
            return candidate
        }).reduce(DetectedCard(), { card, candidate in
            Self.scanners.forEach {
                guard let result = try? $0.scan(text: candidate.string) else { return }
                for element in result {
                    switch element {
                    case let .pan(pan):
                        card.numberCandidates.append(pan)
                        //print(pan)
                    }
                }
            }
            return card
        })
    }
}
