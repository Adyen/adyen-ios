//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class ListCellTests: XCTestCase {

    func test_cell_whenItemSelected_shouldShowSelectedAppearance() throws {
        let selectedBackgroundColor: UIColor = .purple
        let cell = makeCell(
            item: makeItem(
                backgroundColor: selectedBackgroundColor,
                isSelected: true
            )
        )

        let checkmarkImageView: UIImageView = try XCTUnwrap(cell.findView(by: "checkmark"))
        let titleLabel: UILabel = try XCTUnwrap(cell.findView(by: "titleLabel"))
        let titleStackView = try XCTUnwrap(titleLabel.superview)

        XCTAssertEqual(cell.backgroundColor, selectedBackgroundColor)
        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
        XCTAssertEqual(cell.layer.cornerRadius, AdyenUIConstants.defaultCornerRadius)
        XCTAssertTrue(cell.clipsToBounds)
        XCTAssertNotNil(checkmarkImageView.image)
        XCTAssertFalse(checkmarkImageView.isHidden)
        XCTAssertEqual(checkmarkImageView.bounds.size, CGSize(width: 24, height: 24))
        XCTAssertEqual(checkmarkImageView.frame.minX - titleStackView.frame.maxX, 20, accuracy: 0.1)
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertTrue(cell.accessibilityTraits.contains(.selected))
    }

    func test_cell_whenSelectionChanges_shouldUpdateSelectedAppearance() throws {
        let selectedBackgroundColor: UIColor = .purple
        let unselectedBackgroundColor: UIColor = .orange
        let cell = makeCell(
            item: makeItem(
                backgroundColor: selectedBackgroundColor,
                isSelected: true
            )
        )

        cell.item = makeItem(
            backgroundColor: unselectedBackgroundColor
        )
        cell.layoutIfNeeded()

        let checkmarkImageView: UIImageView = try XCTUnwrap(cell.findView(by: "checkmark"))

        XCTAssertEqual(cell.backgroundColor, unselectedBackgroundColor)
        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
        XCTAssertEqual(cell.layer.cornerRadius, 0)
        XCTAssertFalse(cell.clipsToBounds)
        XCTAssertTrue(checkmarkImageView.isHidden)
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertFalse(cell.accessibilityTraits.contains(.selected))

        cell.item = makeItem(
            backgroundColor: selectedBackgroundColor,
            isSelected: true
        )
        cell.layoutIfNeeded()

        XCTAssertEqual(cell.backgroundColor, selectedBackgroundColor)
        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
        XCTAssertEqual(cell.layer.cornerRadius, AdyenUIConstants.defaultCornerRadius)
        XCTAssertTrue(cell.clipsToBounds)
        XCTAssertFalse(checkmarkImageView.isHidden)
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertTrue(cell.accessibilityTraits.contains(.selected))
    }

    func test_cell_whenSelectedItemHasTrailingText_shouldShowTrailingTextAndCheckmark() throws {
        let trailingText = "Trailing text"
        let cell = makeCell(
            item: makeItem(
                backgroundColor: .purple,
                isSelected: true,
                trailingInfo: .text(trailingText)
            )
        )

        let trailingTextLabel: UILabel = try XCTUnwrap(cell.findView(by: "trailingTextLabel"))
        let checkmarkImageView: UIImageView = try XCTUnwrap(cell.findView(by: "checkmark"))

        XCTAssertEqual(trailingTextLabel.text, trailingText)
        XCTAssertFalse(trailingTextLabel.isHidden)
        XCTAssertFalse(checkmarkImageView.isHidden)
        XCTAssertEqual(checkmarkImageView.frame.minX - trailingTextLabel.frame.maxX, 20, accuracy: 0.1)
    }

    func test_setContentInsets_shouldApplyCustomInsetsAndRestoreDefaults() throws {
        let cell = makeCell(item: makeItem(backgroundColor: .purple))
        let itemView: UIView = try XCTUnwrap(cell.findView(by: "itemView"))
        let defaultInsets = UIEdgeInsets(
            top: 0,
            left: cell.contentView.layoutMargins.left,
            bottom: 0,
            right: cell.contentView.layoutMargins.right
        )
        let customInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)

        cell.setContentInsets(.zero)
        XCTAssertEqual(itemView.layoutMargins, defaultInsets)

        cell.setContentInsets(customInsets)
        XCTAssertEqual(itemView.layoutMargins, customInsets)

        cell.setContentInsets(.zero)
        XCTAssertEqual(itemView.layoutMargins, defaultInsets)
    }

    func test_cell_whenCustomHighlightColorProvided_shouldApplyAndResetHighlightColor() {
        let backgroundColor: UIColor = .purple
        let highlightedBackgroundColor: UIColor = .orange
        let cell = makeCell(
            item: makeItem(
                backgroundColor: backgroundColor,
                highlightedBackgroundColor: highlightedBackgroundColor
            )
        )

        cell.setHighlighted(true, animated: false)

        XCTAssertEqual(cell.contentView.backgroundColor, highlightedBackgroundColor)

        cell.setHighlighted(false, animated: false)

        XCTAssertEqual(cell.contentView.backgroundColor, backgroundColor)
    }

    func test_cell_whenHighlightColorOmitted_shouldKeepContentBackgroundClearWhileHighlighting() {
        let cell = makeCell(
            item: makeItem(backgroundColor: .purple)
        )

        cell.setHighlighted(true, animated: false)

        XCTAssertEqual(cell.contentView.backgroundColor, .clear)

        cell.setHighlighted(false, animated: false)

        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
    }

    private func makeCell(item: ListItem) -> ListCell {
        let cell = ListCell(style: .default, reuseIdentifier: nil)
        cell.frame = CGRect(x: 0, y: 0, width: 361, height: 68)
        cell.item = item
        cell.layoutIfNeeded()
        return cell
    }

    private func makeItem(
        backgroundColor: UIColor,
        highlightedBackgroundColor: UIColor? = nil,
        isSelected: Bool = false,
        trailingInfo: ListItem.TrailingInfoType? = nil
    ) -> ListItem {
        var style = ListItemStyle()
        style.backgroundColor = backgroundColor
        style.highlightedBackgroundColor = highlightedBackgroundColor

        return ListItem(
            title: "Title",
            trailingInfo: trailingInfo,
            style: style,
            identifier: "identifier",
            isSelected: isSelected
        )
    }
}
