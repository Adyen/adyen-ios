//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
import Combine
import Testing
import UIKit

@MainActor
struct StoredCardInputViewControllerTests {

    // MARK: - A: UI Display

    @Test
    func viewDidLoad_callsViewModelViewDidLoad() {
        let (proxy, viewModel) = makeSUT()
        proxy.load()
        #expect(viewModel.viewDidLoadCallsCount == 1)
    }

    @Test
    func viewDidLoad_configuresLabelsAndButtonsFromViewModel() throws {
        let titleText = "Enter security code"
        let subtitleText = "Use your Visa card"
        let submitTitle = "Pay €9.99"

        let (proxy, _) = makeSUT(
            titleText: titleText,
            subtitleText: subtitleText,
            submitButtonTitle: submitTitle
        )
        proxy.load()

        #expect(try proxy.titleLabelText == titleText)
        #expect(try proxy.subtitleLabelText == subtitleText)
        #expect(try proxy.primaryButtonTitle == submitTitle)
    }

    @Test
    func viewDidLoad_setsIsModalInPresentation() {
        let (proxy, _) = makeSUT()
        proxy.load()
        #expect(proxy.viewController.isModalInPresentation)
    }

    @Test
    func viewDidLoad_hasBackNavigationButton() {
        let (proxy, _) = makeSUT()
        proxy.load()
        #expect(proxy.viewController.navigationItem.leftBarButtonItem != nil)
    }

    // MARK: - B: Primary button tap

    @Test
    func primaryButtonTap_callsSubmit() async throws {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        try proxy.tapPrimaryButton()

        // submit is dispatched inside a Task — yield to let it run
        for _ in 0..<10 {
            await Task.yield()
        }

        #expect(viewModel.submitCallsCount == 1)
    }

    // MARK: - C: View model callbacks → UI

    @Test
    func inProgressPublisher_updatesPrimaryButtonState() async throws {
        let inProgressSource = StoredCardInputInProgressSource()
        let (proxy, _) = makeSUT(inProgressPublisher: inProgressSource.$isInProgress)
        proxy.load()

        let button = try proxy.primaryButton()
        #expect(!button.showsActivityIndicator)
        #expect(button.isEnabled)

        inProgressSource.isInProgress = true
        await Task.yield()

        #expect(button.showsActivityIndicator)
        #expect(!button.isEnabled)

        inProgressSource.isInProgress = false
        await Task.yield()

        #expect(!button.showsActivityIndicator)
        #expect(button.isEnabled)
    }

    @Test
    func onSecurityCodeValidationRequested_setsInvalidStateOnItem() {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        viewModel.onSecurityCodeValidationRequested?()

        if case .invalid = viewModel.securityCodeItem.validationState {
            // pass
        } else {
            Issue.record("Expected validationState to be .invalid after onSecurityCodeValidationRequested callback")
        }
    }

    @Test
    func viewDidLoad_assignsOnSecurityCodeValidationRequestedCallback() {
        let (proxy, viewModel) = makeSUT()
        #expect(viewModel.onSecurityCodeValidationRequested == nil)

        proxy.load()

        #expect(viewModel.onSecurityCodeValidationRequested != nil)
    }

    // MARK: - D: Secondary button and back button

    @Test
    func backButtonTap_callsDismiss() {
        let (proxy, viewModel) = makeSUT()
        proxy.load()

        proxy.tapBackButton()

        #expect(viewModel.dismissCallsCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        titleText: String = "Enter security code",
        subtitleText: String = "Use your Visa card",
        submitButtonTitle: String = "Pay €1.00",
        inProgressPublisher: Published<Bool>.Publisher? = nil
    ) -> (proxy: StoredCardInputViewControllerProxy, viewModel: StoredCardInputViewModelProtocolMock) {
        let viewModel = StoredCardInputViewModelProtocolMock()
        viewModel.underlyingTitleText = titleText
        viewModel.underlyingSubtitleText = NSAttributedString(string: subtitleText)
        viewModel.underlyingSubmitButtonTitle = submitButtonTitle
        viewModel.underlyingTheme = .default
        viewModel.underlyingInProgressPublisher = inProgressPublisher ?? StoredCardInputInProgressSource().$isInProgress
        viewModel.underlyingSecurityCodeItem = FormCardSecurityCodeItem()
        viewModel.underlyingCardImageItem = CardImageItem(
            imageURL: nil,
            sizeMode: .fixed(CGSize(width: 80, height: 52)),
            theme: .default
        )

        let viewController = StoredCardInputViewController(viewModel: viewModel)
        return (StoredCardInputViewControllerProxy(viewController: viewController), viewModel)
    }
}

// MARK: - StoredCardInputViewControllerProxy

@MainActor
struct StoredCardInputViewControllerProxy {
    let viewController: StoredCardInputViewController

    func load() {
        viewController.loadViewIfNeeded()
    }

    var titleLabelText: String {
        get throws {
            let label = try #require(
                viewController.view.findView(by: "title") as? UILabel,
                "Cannot find title label"
            )
            return try #require(label.text)
        }
    }

    var subtitleLabelText: String {
        get throws {
            let label = try #require(
                viewController.view.findView(by: "subTitle") as? UILabel,
                "Cannot find subtitle label"
            )
            return try #require(label.attributedText?.string)
        }
    }

    var primaryButtonTitle: String {
        get throws {
            let button = try primaryButton()
            return try #require(button.title)
        }
    }

    func primaryButton() throws -> FormButton {
        try #require(
            viewController.view.findView(by: "primaryButton") as? FormButton,
            "Cannot find primaryButton"
        )
    }

    func tapPrimaryButton() throws {
        try primaryButton().sendActions(for: .touchUpInside)
    }

    func tapBackButton() {
        let backButton = viewController.navigationItem.leftBarButtonItem
        _ = backButton?.target?.perform(backButton?.action)
    }
}

@MainActor
private final class StoredCardInputInProgressSource {
    @Published var isInProgress: Bool = false
}
