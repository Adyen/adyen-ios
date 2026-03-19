//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct CardImageItemTests {

    @Test(arguments: [
        (CGSize(width: 80, height: 52), "80x52"),
        (CGSize(width: 120, height: 80), "120x80"),
        (.zero, "zero")
    ])
    func fixedSizeMode_returnsFixedSize(size: CGSize, label: String) {
        // Given
        let sizeMode = CardImageItem.SizeMode.fixed(size)

        // Then
        #expect(sizeMode.initialSize == size)
    }

    @Test(arguments: [
        (CGSize(width: 80, height: 52), "80x52"),
        (CGSize(width: 200, height: 130), "200x130")
    ])
    func variableSizeMode_returnsInitialSize(size: CGSize, label: String) {
        // Given
        let sizeMode = CardImageItem.SizeMode.variable(size)

        // Then
        #expect(sizeMode.initialSize == size)
    }

    @Test func initStoresProperties() throws {
        // Given
        let url = try #require(URL(string: "https://example.com/card.png"))
        let size = CGSize(width: 80, height: 52)

        // When
        let item = CardImageItem(imageURL: url, sizeMode: .fixed(size), theme: .default)

        // Then
        #expect(item.imageURL == url)
        if case let .fixed(storedSize) = item.sizeMode {
            #expect(storedSize == size)
        } else {
            Issue.record("Expected fixed size mode")
        }
    }

    @Test func initWithNilURL() {
        // When
        let item = CardImageItem(imageURL: nil, sizeMode: .fixed(CGSize(width: 80, height: 52)), theme: .default)

        // Then
        #expect(item.imageURL == nil)
    }
}

@MainActor
struct CardImageViewTests {

    // MARK: - Initialization & Layout

    @Test func init_setsUpSubviews() {
        // Given / When
        let item = makeItem()
        let sut = CardImageView(item: item, imageLoader: ImageLoaderMock())

        // Then
        #expect(sut.subviews.count == 1, "Expected one container subview")
    }

    @Test func init_appliesFixedSizeConstraints() {
        // Given
        let size = CGSize(width: 80, height: 52)
        let item = makeItem(sizeMode: .fixed(size))

        // When
        let sut = CardImageView(item: item, imageLoader: ImageLoaderMock())

        // Then
        let containerView = sut.subviews.first
        let widthConstraint = containerView?.constraints.first { $0.firstAttribute == .width }
        let heightConstraint = containerView?.constraints.first { $0.firstAttribute == .height }

        #expect(widthConstraint?.constant == size.width)
        #expect(heightConstraint?.constant == size.height)
    }

    @Test func init_appliesVariableSizeInitialConstraints() {
        // Given
        let initialSize = CGSize(width: 100, height: 65)
        let item = makeItem(sizeMode: .variable(initialSize))

        // When
        let sut = CardImageView(item: item, imageLoader: ImageLoaderMock())

        // Then
        let containerView = sut.subviews.first
        let widthConstraint = containerView?.constraints.first { $0.firstAttribute == .width }
        let heightConstraint = containerView?.constraints.first { $0.firstAttribute == .height }

        #expect(widthConstraint?.constant == initialSize.width)
        #expect(heightConstraint?.constant == initialSize.height)
    }

    // MARK: - Shadow

    @Test func init_appliesShadowToContainer() throws {
        // Given / When
        let item = makeItem()
        let sut = CardImageView(item: item, imageLoader: ImageLoaderMock())

        // Then
        let containerView = try #require(sut.subviews.first)
        #expect(containerView.layer.shadowOpacity == AdyenUIConstants.shadowOpacity)
        #expect(containerView.layer.shadowRadius == AdyenUIConstants.shadowRadius)
        #expect(containerView.layer.shadowOffset == AdyenUIConstants.shadowOffset)
        #expect(containerView.layer.masksToBounds == false)
    }

    // MARK: - Image Loading

    @Test func didMoveToWindow_triggersImageLoad() {
        // Given
        let imageLoader = ImageLoaderMock()
        let item = makeItem(url: "https://example.com/card.png")
        let sut = CardImageView(item: item, imageLoader: imageLoader)

        // When
        addToWindow(sut)

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

    @Test func onImageLoaded_calledAfterImageLoads() async {
        // Given
        let imageLoader = ImageLoaderMock()
        let item = makeItem(url: "https://example.com/card.png")
        let sut = CardImageView(item: item, imageLoader: imageLoader)

        // When / Then
        await confirmation("onImageLoaded called") { confirm in
            sut.onImageLoaded = {
                confirm()
            }
            addToWindow(sut)
        }
    }

    @Test func variableSizeMode_updatesConstraintsOnImageLoad() async throws {
        // Given
        let imageSize = CGSize(width: 200, height: 130)
        let imageLoader = ImageLoaderMock()
        imageLoader.imageProvider = { _ in
            UIGraphicsImageRenderer(size: imageSize).image { context in
                UIColor.red.setFill()
                context.fill(CGRect(origin: .zero, size: imageSize))
            }
        }

        let initialSize = CGSize(width: 80, height: 52)
        let item = makeItem(url: "https://example.com/card.png", sizeMode: .variable(initialSize))
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

        #expect(widthConstraint?.constant == imageSize.width)
        #expect(heightConstraint?.constant == imageSize.height)
    }

    @Test func fixedSizeMode_doesNotUpdateConstraintsOnImageLoad() async throws {
        // Given
        let imageSize = CGSize(width: 200, height: 130)
        let imageLoader = ImageLoaderMock()
        imageLoader.imageProvider = { _ in
            UIGraphicsImageRenderer(size: imageSize).image { context in
                UIColor.red.setFill()
                context.fill(CGRect(origin: .zero, size: imageSize))
            }
        }

        let fixedSize = CGSize(width: 80, height: 52)
        let item = makeItem(url: "https://example.com/card.png", sizeMode: .fixed(fixedSize))
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

        #expect(widthConstraint?.constant == fixedSize.width, "Fixed size should not change after image loads")
        #expect(heightConstraint?.constant == fixedSize.height, "Fixed size should not change after image loads")
    }

    // MARK: - Helpers

    private func makeItem(
        url: String? = "https://example.com/card.png",
        sizeMode: CardImageItem.SizeMode = .fixed(CGSize(width: 80, height: 52))
    ) -> CardImageItem {
        CardImageItem(
            imageURL: url.flatMap { URL(string: $0) },
            sizeMode: sizeMode,
            theme: .default
        )
    }

    private func addToWindow(_ view: UIView) {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        let viewController = UIViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.view.addSubview(view)
        viewController.loadViewIfNeeded()
    }
}
