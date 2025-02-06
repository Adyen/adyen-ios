//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CoreImage.CIFilterBuiltins
import Foundation
import Vision

protocol CardImageParsing {
    func parse(
        image: CIImage,
        completion: @escaping (CreditCard) -> Void
    )
}

class CardImageParser: CardImageParsing {

    private enum Constants {
        static let expireDateRegex = "\\d{2}\\/\\d{2,4}"
        static let topCandidates = 10

        static let cardNumberConfidence: Float = 0.4
        static let expireDateConfidence: Float = 0.4
    }

    // MARK: - Properties

    private let expireDateFormatter: ExpireDateFormatting
    private var cachedCardNumber: String?
    private var cachedExpireDate: Date?

    // MARK: - Initializers

    init(expireDateFormatter: ExpireDateFormatting) {
        self.expireDateFormatter = expireDateFormatter
    }

    // MARK: - CardImageParsing

    func parse(
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
            if self.cachedExpireDate == nil {
                self.cachedExpireDate = self.extractExpireDate(from: results)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            guard let cardNumber = self.cachedCardNumber, let expireDate = self.cachedExpireDate else { return }
            let card = CreditCard(number: cardNumber, expireDate: expireDate)
            completion(card)
        }
    }

    // MARK: - Private

    private func transform(image: CIImage) -> CIImage? {
        return image
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
            .filter { $0.isCardNumber }
            .filter { isValidLuhn($0) }
            .first
        guard let cardNumberMatch else { return nil }
        self.cachedCardNumber = cardNumberMatch

        return cardNumberMatch
    }

    private func extractExpireDate(from textObservations: [VNRecognizedTextObservation]) -> Date? {
        if let cachedExpireDate { return cachedExpireDate }

        let match = textObservations
            .compactMap { $0.topCandidates(Constants.topCandidates).first }
            .filter { $0.confidence > Constants.expireDateConfidence }
            .compactMap { extractMatch(from: $0.string, using: Constants.expireDateRegex) }
            .first
        guard let match else { return nil }
        let expireDate = expireDateFormatter.date(from: match)
        self.cachedExpireDate = expireDate

        return expireDate
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

    private func extractMatch(from text: String, using regex: String) -> String? {
        let regex = try? NSRegularExpression(pattern: regex)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let match = matches?.first, let range = Range(match.range, in: text) else { return nil }
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
