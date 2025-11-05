//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class AdyenLabelStylesInitializerTests: XCTestCase {
    
    func test_defaultInitialization_shouldUseDefaultStyles() {
        // Given & When
        let styles = AdyenLabelStyles()

        // Then
        XCTAssertEqual(styles.title.font, UIFont.systemFont(ofSize: 34.0, weight: .bold))
        XCTAssertEqual(styles.body.font, UIFont.systemFont(ofSize: 17.0, weight: .regular))
        XCTAssertEqual(styles.footnote.font, UIFont.systemFont(ofSize: 13.0, weight: .regular))
    }

    func test_partialOverride_onlyTitle_shouldUseDefaultsForOthers() {
        // Given
        let customTitle = AdyenLabelStyle(
            font: .systemFont(ofSize: 42),
            color: .red
        )

        // When
        let styles = AdyenLabelStyles(title: customTitle)

        // Then
        XCTAssertEqual(styles.title, customTitle)
        XCTAssertEqual(styles.body, AdyenLabelStyles.default.body)
        XCTAssertEqual(styles.footnote, AdyenLabelStyles.default.footnote)
    }

    func test_multipleOverrides_titleAndBody_shouldPreserveOthers() {
        // Given
        let customTitle = AdyenLabelStyle(font: .systemFont(ofSize: 42), color: .red)
        let customBody = AdyenLabelStyle(font: .systemFont(ofSize: 18), color: .blue)

        // When
        let styles = AdyenLabelStyles(
            title: customTitle,
            body: customBody
        )

        // Then
        XCTAssertEqual(styles.title, customTitle)
        XCTAssertEqual(styles.body, customBody)
        XCTAssertEqual(styles.subtitle, AdyenLabelStyles.default.subtitle)
        XCTAssertEqual(styles.footnote, AdyenLabelStyles.default.footnote)
    }

    func test_allCustomLabels_shouldUseAllProvidedValues() {
        // Given
        let customTitle = AdyenLabelStyle(font: .systemFont(ofSize: 42), color: .red)
        let customSubtitle = AdyenLabelStyle(font: .systemFont(ofSize: 24), color: .blue)
        let customBody = AdyenLabelStyle(font: .systemFont(ofSize: 18), color: .black)
        let customBodyEmphasized = AdyenLabelStyle(font: .systemFont(ofSize: 18, weight: .bold), color: .black)
        let customSubheadline = AdyenLabelStyle(font: .systemFont(ofSize: 16), color: .gray)
        let customSubheadlineEmphasized = AdyenLabelStyle(font: .systemFont(ofSize: 16, weight: .bold), color: .gray)
        let customFootnote = AdyenLabelStyle(font: .systemFont(ofSize: 12), color: .lightGray)
        let customFootnoteEmphasized = AdyenLabelStyle(font: .systemFont(ofSize: 12, weight: .bold), color: .lightGray)

        // When
        let styles = AdyenLabelStyles(
            title: customTitle,
            subtitle: customSubtitle,
            body: customBody,
            bodyEmphasized: customBodyEmphasized,
            subheadline: customSubheadline,
            subheadlineEmphasized: customSubheadlineEmphasized,
            footnote: customFootnote,
            footnoteEmphasized: customFootnoteEmphasized
        )

        // Then
        XCTAssertEqual(styles.title, customTitle)
        XCTAssertEqual(styles.subtitle, customSubtitle)
        XCTAssertEqual(styles.body, customBody)
        XCTAssertEqual(styles.bodyEmphasized, customBodyEmphasized)
        XCTAssertEqual(styles.subheadline, customSubheadline)
        XCTAssertEqual(styles.subheadlineEmphasized, customSubheadlineEmphasized)
        XCTAssertEqual(styles.footnote, customFootnote)
        XCTAssertEqual(styles.footnoteEmphasized, customFootnoteEmphasized)
    }

}
