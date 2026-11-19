//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class FormCardExpiryDateItemViewTests: XCTestCase {
    ///
    func testAccessibilityLabelWithEmptyTitle() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = nil
        sut.item.placeholder = "MM/YY"

        // Then
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, localizedString(.cardExpiryItemAccessibilityLabel, nil))
    }

    func testAccessibilityLabelWithTitle() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())

        sut.item.title = "Expiry date"
        sut.item.placeholder = nil

        // Then
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Expiry date, \(format)")
    }

    func testAccessibilityLabelWhenTitleChanges() {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.item.title = "Expiry date"
        sut.item.placeholder = "MM/YY"

        // When title is updated
        sut.item.title = "Card expiration date"

        // Then
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Card expiration date, \(format)")
    }

    func test_accessory_givenEmptyDate_shouldShowExpiryDateHint() throws {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())

        // Then
        let hintView = try XCTUnwrap(sut.hintAccessoryView as? UIImageView)
        XCTAssertNotNil(hintView.image)
        XCTAssertEqual(sut.accessory, .customView(hintView))
    }

    func test_accessory_whenValidDateEnteredWhileEditing_shouldShowCheckmark() throws {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)

        // When
        sut.textField.text = try futureExpiryDate()
        sut.textField.sendActions(for: .editingChanged)

        // Then
        XCTAssertEqual(sut.accessory, .valid)
    }

    func test_accessory_givenOptionalAndEmptyDate_shouldShowExpiryDateHint() throws {
        // Given
        let item = FormCardExpiryDateItem()
        let sut = makeSUT(item: item)

        // When
        item.isOptional = true

        // Then
        XCTAssertEqual(sut.accessory, try .customView(XCTUnwrap(sut.hintAccessoryView)))
    }

    func testAccessibilityLabelSetWithoutItemUpdates() {
        // Given
        let item = FormCardExpiryDateItem()
        item.title = "Expiry date"
        item.placeholder = "MM/YY"

        // When view is created
        let sut = makeSUT(item: item)

        // Then
        let format = localizedString(.cardExpiryItemAccessibilityLabel, nil)
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Expiry date, \(format)")
    }

    func test_hintAccessoryView_whenDeletingAfterValidDate_shouldNotStretch() throws {
        // Given
        let sut = makeSUT(item: FormCardExpiryDateItem())
        let window = layOutInWindow(sut)
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
        sut.textField.text = try futureExpiryDate()
        sut.textField.sendActions(for: .editingChanged)
        window.layoutIfNeeded()

        // When
        sut.textField.text = String(sut.textField.text?.dropLast(2) ?? "")
        sut.textField.sendActions(for: .editingChanged)
        window.layoutIfNeeded()

        // Then
        let hintView = try XCTUnwrap(sut.hintAccessoryView)
        XCTAssertEqual(sut.accessory, .customView(hintView))
        XCTAssertFalse(sut.textField.hasAmbiguousLayout)
        XCTAssertEqual(hintView.frame.width, hintView.intrinsicContentSize.width, accuracy: 0.5)
    }
}

extension FormCardExpiryDateItemViewTests {
    private func makeSUT(item: FormCardExpiryDateItem) -> FormTextInputItemView {
        guard let view = item.build(with: FormItemViewBuilder()) as? FormTextInputItemView else {
            XCTFail("Expected the expiry date item to build a FormTextInputItemView")
            return FormTextInputItemView(item: item)
        }
        return view
    }

    private func futureExpiryDate() throws -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMyy"
        let date = try XCTUnwrap(Calendar.current.date(byAdding: .year, value: 2, to: Date()))
        return formatter.string(from: date)
    }

    private func layOutInWindow(_ view: UIView) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        view.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            view.topAnchor.constraint(equalTo: window.topAnchor)
        ])
        window.isHidden = false
        window.layoutIfNeeded()
        return window
    }
}
