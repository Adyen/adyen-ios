//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct ComponentContainerViewControllerTests {

    // MARK: - Tests

    @Test
    func viewDidDisappear_shouldCallViewModelCancel() async {
        // Given
        let (sut, viewModelMock, _) = await makeSUT()

        // When
        sut.viewDidDisappear(true)

        // Then
        #expect(viewModelMock.cancelCallsCount == 1)
    }

    @Test
    func componentView_shouldMatchViewModelComponentViewController() async {
        // Given
        let (sut, _, expectedComponentViewController) = await makeSUT()

        // When
        let receivedComponentViewController = sut.componentViewController

        // Then
        #expect(expectedComponentViewController === receivedComponentViewController)
    }

    @Test("Verify component is added to the container")
    func viewDidLoad_shouldSetComponentViewControllerAsChild() async throws {
        // Given
        let (sut, _, componentViewControllerMock) = await makeSUT()

        // When
        sut.loadViewIfNeeded()

        // Then
        #expect(sut.children.count == 1)

        let childViewController = try #require(sut.children.first)
        #expect(childViewController === componentViewControllerMock)
    }

    @Test
    func navigationItem() async {
        // Given
        let (sut, _, componentViewControllerMock) = await makeSUT()
        let expectedNavigationItemTitle = componentViewControllerMock.title

        // When
        sut.loadViewIfNeeded()
        let receivedNavigationItemTitle = sut.navigationItem.title

        // Then
        #expect(expectedNavigationItemTitle == receivedNavigationItemTitle)
        #expect(sut.navigationItem.largeTitleDisplayMode == .always)
    }

    // MARK: - Mocks

    private class ComponentContainerViewModelProtocolMock: ComponentContainerViewModelProtocol {
        var componentViewController: UIViewController = .init()
        var cancelCallsCount = 0

        func cancel() {
            cancelCallsCount += 1
        }
    }

    // MARK: - Helper

    private func makeSUT() async -> (
        sut: ComponentContainerViewController,
        viewModelMock: ComponentContainerViewModelProtocolMock,
        componentViewControllerMock: UIViewController
    ) {
        let viewModelMock = ComponentContainerViewModelProtocolMock()
        let componentViewControllerMock = UIViewController()
        componentViewControllerMock.title = "Payment Component"
        viewModelMock.componentViewController = componentViewControllerMock

        let sut = ComponentContainerViewController(viewModel: viewModelMock)

        return (sut, viewModelMock, componentViewControllerMock)
    }
}
