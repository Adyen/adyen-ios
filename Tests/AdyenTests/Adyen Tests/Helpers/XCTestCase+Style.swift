//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

extension XCTestCase {
    
    /// Checks whether the given style was applied properly to the given label
    /// - Parameters:
    ///   - label: `UILabel` to check
    ///   - style: `TextStyle` that should be applied
    func check(label: UILabel, forStyle style: TextStyle) {
        XCTAssertEqual(label.font, style.font)
        XCTAssertEqual(label.textColor, style.color)
        XCTAssertEqual(label.textAlignment, style.textAlignment)
        XCTAssertEqual(label.backgroundColor, style.backgroundColor)
        
        check(layer: label.layer, forCornerRounding: style.cornerRounding)
    }
    
    /// Checks whether the given style was applied properly to the given button
    /// - Parameters:
    ///   - button: `UIButton` to check
    ///   - style: `ButtonStyle` that should be applied
    func check(button: UIButton, forStyle style: ButtonStyle) {
        button.titleLabel.map { check(label: $0, forStyle: style.title) }
        XCTAssertEqual(button.titleColor(for: .normal), style.title.color)
        XCTAssertEqual(button.layer.borderColor, style.borderColor?.cgColor)
        XCTAssertEqual(button.layer.borderWidth, style.borderWidth)
        XCTAssertEqual(button.backgroundColor, style.backgroundColor)
        
        check(layer: button.layer, forCornerRounding: style.cornerRounding)
    }
    
    /// Checks whether the given style was applied properly to the given `SubmitButton`
    /// - Parameters:
    ///   - submitButton: `SubmitButton` to check
    ///   - style: `ButtonStyle` that should be applied
    func check(submitButton: SubmitButton, forStyle style: ButtonStyle) {
        check(label: submitButton.titleLabel, forStyle: style.title)
        XCTAssertEqual(submitButton.backgroundView.layer.borderColor, style.borderColor?.cgColor)
        XCTAssertEqual(submitButton.backgroundView.layer.borderWidth, style.borderWidth)
        XCTAssertEqual(submitButton.backgroundView.backgroundColor, style.backgroundColor)
        
        check(layer: submitButton.layer, forCornerRounding: style.cornerRounding)
    }
    
    /// Checks whether the given corner rounding was applied properly to the given layer
    /// - Parameters:
    ///   - layer: `CALayer` to check
    ///   - cornerRounding: `CornerRounding` that should be applied
    func check(layer: CALayer, forCornerRounding cornerRounding: CornerRounding) {
        switch cornerRounding {
        case .none:
            break
        case let .fixed(radius):
            XCTAssertEqual(layer.cornerRadius, radius)
        case let .percent(percent):
            let radius = min(layer.frame.width, layer.frame.height) * percent
            XCTAssertEqual(layer.cornerRadius, radius)
        }
    }
    
}
