//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CoreImage.CIFilterBuiltins
import Foundation
import Vision

internal protocol CardImageParsing {
    func parse(
        image: CIImage,
        completion: @escaping (CreditCard) -> Void
    )
}

@available(iOS 13.0, *)
internal class CardImageParser: CardImageParsing {

    private enum Constants {
        static let expirationDateRegex = #"(0[1-9]|1[0-2])[\/\-](\d{2}|\d{4})"#
        static let topCandidates = 10

        static let cardNumberConfidence: Float = 0.4
        static let expirationDateConfidence: Float = 0.4
    }

    // MARK: - Properties

    private let expirationDateFormatter: ExpirationDateFormatting
    private var cachedCardNumber: String?
    private var cachedExpirationDate: Date?

    // MARK: - Initializers

    internal init(expirationDateFormatter: ExpirationDateFormatting) {
        self.expirationDateFormatter = expirationDateFormatter
    }

    // MARK: - CardImageParsing

    internal func parse(
        image: CIImage,
        completion: @escaping (CreditCard) -> Void
    ) {
        guard let transformedImage = transform(image: image) else { return }

        let recognizeTextRequest = VNRecognizeTextRequest()
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.usesLanguageCorrection = false

        let imageRequestHandler = VNImageRequestHandler(ciImage: transformedImage, options: [:])
        try? imageRequestHandler.perform([recognizeTextRequest])

        guard let results = recognizeTextRequest.results, !results.isEmpty else {
            return
        }

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        DispatchQueue.global().async {
            if self.cachedCardNumber == nil {
                self.cachedCardNumber = self.extractCardNumber(from: results)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        DispatchQueue.global().async {
            if self.cachedExpirationDate == nil {
                self.cachedExpirationDate = self.extractExpirationDate(from: results)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            guard let cardNumber = self.cachedCardNumber,
                  let expirationDate = self.cachedExpirationDate else {
                return
            }
            let card = CreditCard(number: cardNumber, expirationDate: expirationDate)
            completion(card)
        }
    }

    // MARK: - Private

    private func transform(image: CIImage) -> CIImage? {
        image
            .applyNoiseReductionFilter()?
            .applyColorControlsFilter()?
            .applySharpnessEnhancementFilter()
    }

    private func extractCardNumber(from textObservations: [VNRecognizedTextObservation]) -> String? {
        if let cachedCardNumber { return cachedCardNumber }

        let cardNumberMatch = textObservations
            .compactMap { $0.topCandidates(Constants.topCandidates).first }
            .filter { $0.confidence > Constants.cardNumberConfidence }
            .map { $0.string.replacingOccurrences(of: " ", with: "") }
            .first(where: { $0.isCardNumber && isValidLuhn($0) })
        guard let cardNumberMatch else { return nil }
        self.cachedCardNumber = cardNumberMatch
        
        return cardNumberMatch
    }
    
    private let expirationDateRegex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: Constants.expirationDateRegex, options: [])
    }()

    private func extractExpirationDate(from textObservations: [VNRecognizedTextObservation]) -> Date? {
        if let cachedExpirationDate { return cachedExpirationDate }

        let match = textObservations
            .compactMap { $0.topCandidates(Constants.topCandidates).first }
            .filter { $0.confidence > Constants.expirationDateConfidence }
            .compactMap { extractMatch(from: $0.string, using: expirationDateRegex) }
            .first
        guard let match else { return nil }
        let expirationDate = expirationDateFormatter.date(from: match)
        self.cachedExpirationDate = expirationDate
                
        return expirationDate
    }

    private func isValidLuhn(_ number: String) -> Bool {
        guard number.allSatisfy(\.isNumber) else { return false }

        var sum = 0
        let reversedDigits = number.reversed().map { Int(String($0))! }

        for (index, digit) in reversedDigits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += (doubled > 9) ? (doubled - 9) : doubled
            } else {
                sum += digit
            }
        }

        return sum % 10 == 0
    }

    private func extractMatch(from text: String, using regex: NSRegularExpression?) -> String? {
        guard let regex else { return nil }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let match = matches.first, let range = Range(match.range, in: text) else { return nil }
        return String(text[range])
    }
}

private extension String {

    var isCardNumber: Bool {
        let isOnlyNumbers = !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
        let isLengthValid = count >= 12 && count <= 19
        return isOnlyNumbers && isLengthValid
    }
}

@available(iOS 13.0, *)
private extension CIImage {

    func applyNoiseReductionFilter() -> CIImage? {
        let noiseReductionFilter = CIFilter.noiseReduction()
        noiseReductionFilter.inputImage = self
        noiseReductionFilter.noiseLevel = 0.02
        noiseReductionFilter.sharpness = 0.4
        return noiseReductionFilter.outputImage
    }

    func applyColorControlsFilter() -> CIImage? {
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = self
        colorControlsFilter.brightness = 0.2
        colorControlsFilter.contrast = 1.5
        colorControlsFilter.saturation = 1.2
        return colorControlsFilter.outputImage
    }

    func applySharpnessEnhancementFilter() -> CIImage? {
        let sharpenFilter = CIFilter.sharpenLuminance()
        sharpenFilter.inputImage = self
        sharpenFilter.sharpness = 0.5
        return sharpenFilter.outputImage
    }
}
