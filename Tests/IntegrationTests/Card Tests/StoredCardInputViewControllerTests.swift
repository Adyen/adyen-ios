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
    func viewDidLoad_callsViewModelViewDidLoad() async {
        let (proxy, viewModel) = makeSUT()
        await proxy.load()
        #expect(viewModel.viewDidLoadCallsCount == 1)
    }

    @Test
    func viewDidLoad_configuresLabelsAndButtonsFromViewModel() async throws {
        let titleText = "Enter security code"
        let subtitleText = "Use your Visa card"
        let submitTitle = "Pay €9.99"

        let (proxy, _) = makeSUT(
            titleText: titleText,
            subtitleText: subtitleText,
            submitButtonTitle: submitTitle
        )
        await proxy.load()

        #expect(try proxy.titleLabelText == titleText)
        #expect(try proxy.subtitleLabelText == subtitleText)
        #expect(try proxy.primaryButtonTitle == submitTitle)
    }

    @Test
    func viewDidLoad_setsIsModalInPresentation() async {
        let (proxy, _) = makeSUT()
        await proxy.load()
        #expect(proxy.viewController.isModalInPresentation)
    }

    // MARK: - B: Primary button tap

    @Test
    func primaryButtonTap_callsSubmit() async throws {
        let (proxy, viewModel) = makeSUT()
        await proxy.load()

        try proxy.tapPrimaryButton()

        // submit is dispatched inside a Task — yield to let it run
        for _ in 0..<10 {
            await Task.yield()
        }

        #expect(viewModel.submitCallsCount == 1)
    }

    // MARK: - C: View model callbacks → UI

    @Test
    func inProgressPublisher_updatesLoadingState() async throws {
        let inProgressSource = StoredCardInputInProgressSource()
        let (proxy, _) = makeSUT(inProgressPublisher: inProgressSource.$isInProgress)
        await proxy.load()

        let button = try proxy.primaryButton()
        let securityCodeItemView = try proxy.securityCodeItemView()
        #expect(!button.showsActivityIndicator)
        #expect(button.isEnabled)
        #expect(securityCodeItemView.isUserInteractionEnabled)

        inProgressSource.isInProgress = true
        await Task.yield()

        #expect(button.showsActivityIndicator)
        #expect(!button.isEnabled)
        #expect(!securityCodeItemView.isUserInteractionEnabled)

        inProgressSource.isInProgress = false
        await Task.yield()

        #expect(!button.showsActivityIndicator)
        #expect(button.isEnabled)
        #expect(securityCodeItemView.isUserInteractionEnabled)
    }

    @Test
    func onSecurityCodeValidationRequested_setsInvalidStateOnItem() async {
        let (proxy, viewModel) = makeSUT()
        await proxy.load()

        viewModel.onSecurityCodeValidationRequested?()

        if case .invalid = viewModel.securityCodeItem.validationState {
            // pass
        } else {
            Issue.record("Expected validationState to be .invalid after onSecurityCodeValidationRequested callback")
        }
    }

    @Test
    func viewDidLoad_assignsOnSecurityCodeValidationRequestedCallback() async {
        let (proxy, viewModel) = makeSUT()
        #expect(viewModel.onSecurityCodeValidationRequested == nil)

        await proxy.load()

        #expect(viewModel.onSecurityCodeValidationRequested != nil)
    }

    @Test
    func onViewDisappear_callsViewDidDisappear() async {
        let (proxy, viewModel) = makeSUT()
        await proxy.load()

        await proxy.dismissView()

        #expect(viewModel.viewDidDisappearCallsCount == 1)
    }

    // MARK: - D: Security code input behavior

    @Test
    func typingThreeCharactersInSecurityCode_resignsFirstResponder() async throws {
        let (proxy, _) = makeSUT()
        await proxy.load()

        let securityCodeView = try proxy.securityCodeItemView()
        #expect(securityCodeView.isFirstResponder)
        try proxy.enterCode("123")
        #expect(!securityCodeView.isFirstResponder)
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

    private let window = UIWindow(frame: UIScreen.main.bounds)
    private let rootController = UIViewController()

    func load() async {
        window.rootViewController = rootController
        window.makeKeyAndVisible()
        await withCheckedContinuation { continuation in
            rootController.present(viewController, animated: false) {
                viewController.loadViewIfNeeded()
                continuation.resume()
            }
        }
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

    func securityCodeItemView() throws -> FormCardSecurityCodeItemView {
        try #require(
            viewController.view.findView(by: "securityCodeItemView") as? FormCardSecurityCodeItemView,
            "Cannot find securityCodeItemView"
        )
    }

    func enterCode(_ code: String) throws {
        let textField = try securityCodeItemView().textField
        code.forEach { textField.insertText(String($0)) }
        textField.sendActions(for: .editingChanged)
    }

    func tapPrimaryButton() throws {
        try primaryButton().sendActions(for: .touchUpInside)
    }

    func dismissView() async {
        await withCheckedContinuation { continuation in
            rootController.dismiss(animated: false) {
                continuation.resume()
            }
        }
    }
}

@MainActor
private final class StoredCardInputInProgressSource {
    @Published var isInProgress: Bool = false
}
