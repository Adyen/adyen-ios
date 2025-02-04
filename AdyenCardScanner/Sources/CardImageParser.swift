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

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    private var cardNumber: String?
    private var expireDate: Date?

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
            if self.cardNumber == nil {
                self.cardNumber = self.extractCardNumber(from: results)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        DispatchQueue.global().async {
            if self.expireDate == nil {
                self.expireDate = self.extractExpireDate(from: results)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            guard let cardNumber = self.cardNumber, let expireDate = self.expireDate else { return }
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

    // ================== DO NOT REMOVE ==================
    // TODO: - This is logic to grey-scale can image. We want to continue experimenting with it.

    func processImageForTextRecognition(image: CIImage?, threshold: CGFloat) -> CIImage? {
        guard let image else { return nil }
        if let grayscaleImage = convertToGrayscale(image: image) {
            return applyThreshold(image: grayscaleImage, threshold: threshold)
        }
        return nil
    }

    private func convertToGrayscale(image: CIImage) -> CIImage? {
        let colorControlsFilter = CIFilter(name: "CIColorControls")
        colorControlsFilter?.setValue(image, forKey: kCIInputImageKey)
        colorControlsFilter?.setValue(0.0, forKey: kCIInputSaturationKey) // No color
        colorControlsFilter?.setValue(1.0, forKey: kCIInputBrightnessKey) // Full brightness
        colorControlsFilter?.setValue(1.0, forKey: kCIInputContrastKey) // Full contrast
        return colorControlsFilter?.outputImage
    }

    private func applyThreshold(image: CIImage, threshold: CGFloat) -> CIImage? {
        let colorMatrixFilter = CIFilter(name: "CIColorMatrix")
        colorMatrixFilter?.setValue(image, forKey: kCIInputImageKey)

        // Set the threshold value
        let thresholdVector = CIVector(x: threshold, y: threshold, z: threshold, w: 1)
        colorMatrixFilter?.setValue(thresholdVector, forKey: "inputRVector")
        colorMatrixFilter?.setValue(thresholdVector, forKey: "inputGVector")
        colorMatrixFilter?.setValue(thresholdVector, forKey: "inputBVector")

        // Keeping alpha channel as is
        colorMatrixFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")

        // Biasing the output so that it’s either black or white
        let biasVector = CIVector(x: -threshold, y: -threshold, z: -threshold, w: 0)
        colorMatrixFilter?.setValue(biasVector, forKey: "inputBiasVector")

        return colorMatrixFilter?.outputImage
    }

    // ==================================================

    private func extractCardNumber(from textObservations: [VNRecognizedTextObservation]) -> String? {
        for observation in textObservations {
            let candidates = observation.topCandidates(Constants.topCandidates)
            guard let topCandidate = candidates.first,
                  topCandidate.confidence > Constants.cardNumberConfidence else { continue }

            debugPrint("candidates >> \(topCandidate.string)")

            let sanitizedCardNumber = topCandidate.string.replacingOccurrences(of: " ", with: "")

            guard sanitizedCardNumber.isOnlyNumbers else { continue }
            guard sanitizedCardNumber.count >= 13, sanitizedCardNumber.count <= 19 else { continue }
            guard isValidLuhn(sanitizedCardNumber) else { continue }

            debugPrint("VALID CARD: \(sanitizedCardNumber)")

            return sanitizedCardNumber
        }

        return nil
    }

    private func extractExpireDate(from textObservations: [VNRecognizedTextObservation]) -> Date? {
        for observation in textObservations {
            let candidates = observation.topCandidates(Constants.topCandidates)
            guard let topCandidate = candidates.first,
                  topCandidate.confidence > Constants.expireDateConfidence else { continue }

            let expireDateMatch = extractMatch(from: topCandidate.string, using: Constants.expireDateRegex)
            guard let expireDateMatch else { continue }

            debugPrint("VALID DATE: \(expireDateMatch)")
            return date(from: expireDateMatch)
        }

        return nil
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

    private func date(from dateString: String) -> Date? {
        // First, try the short ("MM/YY") format
        dateFormatter.dateFormat = CardExpireDateFormat.short.rawValue
        if let shortYearDate = dateFormatter.date(from: dateString) {
            return shortYearDate
        }

        // Then, try the long ("MM/YYYY") format
        dateFormatter.dateFormat = CardExpireDateFormat.long.rawValue
        return dateFormatter.date(from: dateString)
    }

    private func extractMatch(from text: String, using regex: String) -> String? {
        let regex = try? NSRegularExpression(pattern: regex)
        let matches = regex?.matches(in: text, range: NSRange(text.startIndex..., in: text))
        guard let match = matches?.first, let range = Range(match.range, in: text) else { return nil }
        return String(text[range])
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
