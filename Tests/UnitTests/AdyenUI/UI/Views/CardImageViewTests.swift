//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenUI
import Testing
import UIKit

@MainActor
struct CardImageViewTests {

    // MARK: - Image Loading

    @Test func didMoveToWindow_triggersImageLoad() async {
        // Given
        let imageLoader = ImageLoaderMock()
        let item = makeItem(url: DemoData.cardURL)
        let sut = CardImageView(item: item, imageLoader: imageLoader)

        // When
        await confirmation("onImageLoaded called") { confirm in
            sut.onImageLoaded = {
                confirm()
            }
            addToWindow(sut)
        }

        // Then
        #expect(imageLoader.loadCalled, "Image loading should be triggered when the view is added to a window")
        #expect(imageLoader.loadCallsCount == 1)
    }

    @Test func didMoveToWindow_nilURL_doesNotLoad() {
        // Given
        let imageLoader = ImageLoaderMock()
        let item = makeItem(url: nil)
        let sut = CardImageView(item: item, imageLoader: imageLoader)

        // When
        addToWindow(sut)

        // Then
        #expect(!imageLoader.loadCalled, "Image loading should not be triggered when URL is nil")
    }

    @Test func variableSizeMode_updatesConstraintsOnImageLoad() async throws {
        // Given
        let imageLoader = ImageLoaderMock()
        imageLoader.imageProvider = { _ in DemoData.dummyImage() }

        let item = makeItem(url: DemoData.cardURL, sizeMode: .variable(DemoData.fixedSize))
        let sut = CardImageView(item: item, imageLoader: imageLoader)
        let containerView = try #require(sut.subviews.first)

        // When
        await confirmation("Image loaded") { confirm in
            sut.onImageLoaded = { confirm() }
            addToWindow(sut)
        }

        // Then
        let widthConstraint = containerView.constraints.first { $0.firstAttribute == .width }
        let heightConstraint = containerView.constraints.first { $0.firstAttribute == .height }

        #expect(widthConstraint?.constant == DemoData.loadedImageSize.width)
        #expect(heightConstraint?.constant == DemoData.loadedImageSize.height)
    }

    @Test func fixedSizeMode_doesNotUpdateConstraintsOnImageLoad() async throws {
        // Given
        let imageLoader = ImageLoaderMock()
        imageLoader.imageProvider = { _ in DemoData.dummyImage() }

        let item = makeItem(url: DemoData.cardURL, sizeMode: .fixed(DemoData.fixedSize))
        let sut = CardImageView(item: item, imageLoader: imageLoader)
        let containerView = try #require(sut.subviews.first)

        // When
        await confirmation("Image loaded") { confirm in
            sut.onImageLoaded = { confirm() }
            addToWindow(sut)
        }

        // Then
        let widthConstraint = containerView.constraints.first { $0.firstAttribute == .width }
        let heightConstraint = containerView.constraints.first { $0.firstAttribute == .height }

        #expect(widthConstraint?.constant == DemoData.fixedSize.width, "Fixed size should not change after image loads")
        #expect(heightConstraint?.constant == DemoData.fixedSize.height, "Fixed size should not change after image loads")
    }

    // MARK: - Helpers

    private func makeItem(
        url: String? = DemoData.cardURL,
        sizeMode: CardImageItem.SizeMode = .fixed(DemoData.fixedSize)
    ) -> CardImageItem {
        CardImageItem(
            imageURL: url.flatMap { URL(string: $0) },
            sizeMode: sizeMode,
            theme: .default
        )
    }

    private func addToWindow(_ view: UIView) {
        let window = UIWindow(frame: DemoData.windowSize)
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.view.addSubview(view)
        viewController.loadViewIfNeeded()
    }

    // MARK: - Constants

    private enum DemoData {
        static let cardURL = "https://example.com/card.png"
        static let fixedSize = CGSize(width: 80, height: 52)
        static let loadedImageSize = CGSize(width: 200, height: 130)
        static let windowSize = CGRect(x: 0, y: 0, width: 375, height: 812)

        static func dummyImage(size: CGSize = loadedImageSize) -> UIImage {
            UIGraphicsImageRenderer(size: size).image { context in
                UIColor.red.setFill()
                context.fill(CGRect(origin: .zero, size: size))
            }
        }
    }

}
