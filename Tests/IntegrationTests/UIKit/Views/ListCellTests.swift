//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class ListCellTests: XCTestCase {

    private enum Colors {
        static let background: UIColor = .purple
        static let container: UIColor = .orange
    }

    func test_cell_whenItemSelected_shouldShowSelectedAppearance() throws {
        let cell = makeCell(item: makeItem(isSelected: true))

        let checkmarkImageView: UIImageView = try XCTUnwrap(cell.findView(by: "checkmark"))
        let titleLabel: UILabel = try XCTUnwrap(cell.findView(by: "titleLabel"))
        let titleStackView = try XCTUnwrap(titleLabel.superview)

        XCTAssertEqual(cell.backgroundColor, Colors.container)
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
        let cell = makeCell(item: makeItem(isSelected: true))

        cell.item = makeItem()
        cell.layoutIfNeeded()

        let checkmarkImageView: UIImageView = try XCTUnwrap(cell.findView(by: "checkmark"))

        XCTAssertEqual(cell.backgroundColor, Colors.background)
        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
        XCTAssertEqual(cell.layer.cornerRadius, 0)
        XCTAssertFalse(cell.clipsToBounds)
        XCTAssertTrue(checkmarkImageView.isHidden)
        XCTAssertTrue(cell.accessibilityTraits.contains(.button))
        XCTAssertFalse(cell.accessibilityTraits.contains(.selected))

        cell.item = makeItem(isSelected: true)
        cell.layoutIfNeeded()

        XCTAssertEqual(cell.backgroundColor, Colors.container)
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

    func test_cell_whenHighlighted_shouldKeepContentBackgroundClear() {
        let cell = makeCell(item: makeItem())

        cell.setHighlighted(true, animated: false)

        XCTAssertEqual(cell.contentView.backgroundColor, .clear)

        cell.setHighlighted(false, animated: false)

        XCTAssertEqual(cell.contentView.backgroundColor, .clear)
    }

    func test_cell_whenHorizontalContentInsetProvided_shouldInsetItemViewAndRestoreMargins() throws {
        let cell = makeCell(item: makeItem(horizontalContentInset: 14))
        let itemView: UIView = try XCTUnwrap(cell.findView(by: "itemView"))

        XCTAssertEqual(itemView.frame.minX, 14, accuracy: 0.1)
        XCTAssertEqual(cell.contentView.bounds.maxX - itemView.frame.maxX, 14, accuracy: 0.1)

        cell.item = makeItem()
        cell.layoutIfNeeded()

        XCTAssertEqual(itemView.frame.minX, cell.contentView.layoutMargins.left, accuracy: 0.1)
        XCTAssertEqual(cell.contentView.bounds.maxX - itemView.frame.maxX, cell.contentView.layoutMargins.right, accuracy: 0.1)
    }

    func test_cell_whenTitleEmphasisPrimary_shouldUsePrimaryColorForTitleAndCheckmark() throws {
        let cell = makeCell(item: makeItem(isSelected: true, titleEmphasis: .primary))

        let titleLabel: UILabel = try XCTUnwrap(cell.findView(by: "titleLabel"))
        let checkmarkImageView: UIImageView = try XCTUnwrap(cell.findView(by: "checkmark"))

        XCTAssertEqual(titleLabel.textColor, theme.colors.primary)
        XCTAssertEqual(checkmarkImageView.tintColor, theme.colors.primary)
    }

    func test_cell_whenTitleEmphasisHighlighted_shouldUseHighlightColor() throws {
        let cell = makeCell(item: makeItem(titleEmphasis: .highlighted))

        let titleLabel: UILabel = try XCTUnwrap(cell.findView(by: "titleLabel"))

        XCTAssertEqual(titleLabel.textColor, theme.colors.highlight)
    }

    func test_cell_whenItemHasSubtitle_fittingHeightIncludesLabels() {
        let cell = ListCell(style: .default, reuseIdentifier: nil)
        cell.theme = theme
        cell.item = ListItem(title: "Title", subtitle: "Subtitle", identifier: "identifier")

        let fittingSize = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: 361, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        XCTAssertGreaterThanOrEqual(fittingSize.height, 64)
    }

    // MARK: - Helpers

    private let theme = CheckoutTheme(
        colors: CheckoutColors(
            background: Colors.background,
            container: Colors.container,
            primary: .green,
            highlight: .blue
        )
    )

    private func makeCell(item: ListItem) -> ListCell {
        let cell = ListCell(style: .default, reuseIdentifier: nil)
        cell.frame = CGRect(x: 0, y: 0, width: 361, height: 68)
        cell.theme = theme
        cell.item = item
        cell.layoutIfNeeded()
        return cell
    }

    private func makeItem(
        isSelected: Bool = false,
        titleEmphasis: ListItem.TitleEmphasis = .standard,
        trailingInfo: ListItem.TrailingInfoType? = nil,
        horizontalContentInset: CGFloat? = nil
    ) -> ListItem {
        ListItem(
            title: "Title",
            trailingInfo: trailingInfo,
            titleEmphasis: titleEmphasis,
            horizontalContentInset: horizontalContentInset,
            identifier: "identifier",
            isSelected: isSelected
        )
    }
}
