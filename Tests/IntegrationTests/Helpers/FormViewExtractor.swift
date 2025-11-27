//
// Copyright (c) 2025 Adyen N.V.
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
    ///
    /// Verifies: title color, title font, text color, text font, container color, corner radius
    ///
    /// - Parameters:
    ///   - identifiers: Array of text field identifiers to check
    ///   - style: Expected text field style from TestTheme
    ///   - file: Source file for test failure reporting
    ///   - line: Line number for test failure reporting
    func assertTextFieldsUseTheme(
        _ identifiers: [String],
        style: TestTheme.TextFieldStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for id in identifiers {
            let shortName = id.components(separatedBy: ".").last ?? id

            let titleLabel: UILabel? = view.findView(with: "\(id).titleLabel")
            let textField: UITextField? = view.findView(with: "\(id).textField")
            let entryStackView: UIView? = view.findView(with: "\(id).entryTextStackView")

            // Title label styling
            XCTAssertEqual(
                titleLabel?.textColor, style.titleColor,
                """
                \(shortName) title color mismatch
                  Expected: \(style.titleColor)
                  Actual:   \(String(describing: titleLabel?.textColor))
                """,
                file: file, line: line
            )
            XCTAssertEqual(
                titleLabel?.font, style.titleFont,
                """
                \(shortName) title font mismatch
                  Expected: \(style.titleFont)
                  Actual:   \(String(describing: titleLabel?.font))
                """,
                file: file, line: line
            )

            // Text field styling
            XCTAssertEqual(
                textField?.textColor, style.textColor,
                """
                \(shortName) text color mismatch
                  Expected: \(style.textColor)
                  Actual:   \(String(describing: textField?.textColor))
                """,
                file: file, line: line
            )
            XCTAssertEqual(
                textField?.font, style.textFont,
                """
                \(shortName) text font mismatch
                  Expected: \(style.textFont)
                  Actual:   \(String(describing: textField?.font))
                """,
                file: file, line: line
            )

            // Container styling
            XCTAssertEqual(
                entryStackView?.backgroundColor, style.containerColor,
                """
                \(shortName) container color mismatch
                  Expected: \(style.containerColor)
                  Actual:   \(String(describing: entryStackView?.backgroundColor))
                """,
                file: file, line: line
            )
            XCTAssertEqual(
                entryStackView?.layer.cornerRadius ?? 0, style.cornerRadius, accuracy: 0.1,
                """
                \(shortName) corner radius mismatch
                  Expected: \(style.cornerRadius)
                  Actual:   \(entryStackView?.layer.cornerRadius ?? 0)
                """,
                file: file, line: line
            )
        }
    }

    /// Asserts that a button uses the expected theme styling.
    ///
    /// Verifies: background color, text color, corner radius
    ///
    /// - Parameters:
    ///   - identifier: Button identifier (without ".button" suffix)
    ///   - style: Expected button style from TestTheme
    ///   - file: Source file for test failure reporting
    ///   - line: Line number for test failure reporting
    func assertButtonUsesTheme(
        _ identifier: String,
        style: TestTheme.ButtonStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let shortName = identifier.components(separatedBy: ".").last ?? identifier
        let button: UIControl? = view.findView(with: "\(identifier).button")
        let titleLabel: UILabel? = view.findView(with: "\(identifier).button.titleLabel")

        XCTAssertEqual(
            button?.backgroundColor, style.backgroundColor,
            """
            \(shortName) background color mismatch
              Expected: \(style.backgroundColor)
              Actual:   \(String(describing: button?.backgroundColor))
            """,
            file: file, line: line
        )
        XCTAssertEqual(
            titleLabel?.textColor, style.textColor,
            """
            \(shortName) text color mismatch
              Expected: \(style.textColor)
              Actual:   \(String(describing: titleLabel?.textColor))
            """,
            file: file, line: line
        )
        XCTAssertEqual(
            button?.layer.cornerRadius ?? 0, style.cornerRadius, accuracy: 0.1,
            """
            \(shortName) corner radius mismatch
              Expected: \(style.cornerRadius)
              Actual:   \(button?.layer.cornerRadius ?? 0)
            """,
            file: file, line: line
        )
    }
}
