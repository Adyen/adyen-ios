//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct CheckoutNavigationControllerTests {

    // MARK: - Tests

    @Test("The system bar background is kept, so the bar keeps blurring the content underneath it.")
    func navigationBar_shouldKeepTheDefaultBackground() throws {
        // When
        let sut = makeSUT()

        // Then
        // No background colour is forced, so the bar keeps the system material.
        let appearance = try #require(sut.navigationBar.standardAppearance)
        #expect(appearance.backgroundColor == nil)
        #expect(appearance.shadowColor == UINavigationBarAppearance().shadowColor)

        // A nil scroll edge appearance leaves the system behaviour of a transparent bar at the top of the content.
        #expect(sut.navigationBar.scrollEdgeAppearance == nil)
    }

    @Test("Bar button items are tinted with the theme, so every module gets the same chrome.")
    func navigationBar_shouldApplyTheThemeTintColor() {
        // Given
        let theme = CheckoutTheme(colors: CheckoutColors(primary: .cyan))

        // When
        let sut = makeSUT(theme: theme)

        // Then
        #expect(sut.navigationBar.tintColor == theme.colors.primary)
    }

    @Test("Bar titles use the theme label styles.")
    func navigationBar_shouldApplyTheThemeTitleStyles() throws {
        // Given
        let theme = CheckoutTheme()

        // When
        let sut = makeSUT(theme: theme)

        // Then
        let appearance = try #require(sut.navigationBar.standardAppearance)
        #expect(appearance.titleTextAttributes[.font] as? UIFont == theme.elements.labels.bodyEmphasized.font)
        #expect(appearance.titleTextAttributes[.foregroundColor] as? UIColor == theme.elements.labels.bodyEmphasized.color)
        #expect(appearance.largeTitleTextAttributes[.font] as? UIFont == theme.elements.labels.title.font)
        #expect(appearance.largeTitleTextAttributes[.foregroundColor] as? UIColor == theme.elements.labels.title.color)
    }

    @Test
    func rootViewController_shouldBeTheGivenViewController() throws {
        // Given
        let rootViewController = UIViewController()

        // When
        let sut = makeSUT(rootViewController: rootViewController)

        // Then
        #expect(sut.viewControllers.count == 1)
        #expect(try #require(sut.viewControllers.first) === rootViewController)
    }

    // MARK: - Helpers

    private func makeSUT(
        rootViewController: UIViewController = UIViewController(),
        theme: CheckoutTheme = CheckoutTheme()
    ) -> CheckoutNavigationController {
        CheckoutNavigationController(rootViewController: rootViewController, theme: theme)
    }
}
