//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import XCTest

// MARK: - Theme Assertion Helpers

/// Extension providing theme assertion helpers for UI tests.
/// These methods verify that AdyenTheme styling is correctly applied to form elements.
extension UIViewController {

    /// Asserts that all specified text fields use the expected theme styling.
    func assertTextFieldsUseTheme(
        _ identifiers: [String],
        style: TestTheme.TextFieldStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for id in identifiers {
            let name = id.components(separatedBy: ".").last ?? id
            let titleLabel: UILabel? = view.findView(with: "\(id).titleLabel")
            let textField: UITextField? = view.findView(with: "\(id).textField")
            let container: UIView? = view.findView(with: "\(id).entryTextStackView")

            XCTAssertEqual(
                titleLabel?.textColor,
                style.titleColor,
                "\(name) title color: expected \(style.titleColor)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                titleLabel?.font,
                style.titleFont,
                "\(name) title font: expected \(style.titleFont)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                textField?.textColor,
                style.textColor,
                "\(name) text color: expected \(style.textColor)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                textField?.font,
                style.textFont,
                "\(name) text font: expected \(style.textFont)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                container?.backgroundColor,
                style.containerColor,
                "\(name) container: expected \(style.containerColor)",
                file: file,
                line: line
            )
            XCTAssertEqual(
                container?.layer.cornerRadius ?? 0,
                style.cornerRadius,
                accuracy: 0.1,
                "\(name) radius: expected \(style.cornerRadius)",
                file: file,
                line: line
            )
        }
    }

    /// Asserts that a button uses the expected theme styling.
    func assertButtonUsesTheme(
        _ identifier: String,
        style: TestTheme.ButtonStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let name = identifier.components(separatedBy: ".").last ?? identifier
        let button: UIControl? = view.findView(with: "\(identifier).button")
        let titleLabel: UILabel? = view.findView(with: "\(identifier).button.titleLabel")

        XCTAssertEqual(
            button?.backgroundColor,
            style.backgroundColor,
            "\(name) background: expected \(style.backgroundColor)",
            file: file,
            line: line
        )
        XCTAssertEqual(
            titleLabel?.textColor,
            style.textColor,
            "\(name) text color: expected \(style.textColor)",
            file: file,
            line: line
        )
        XCTAssertEqual(
            button?.layer.cornerRadius ?? 0,
            style.cornerRadius,
            accuracy: 0.1,
            "\(name) radius: expected \(style.cornerRadius)",
            file: file,
            line: line
        )
    }
}
