//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Combine
import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormTextItemView

#endif

internal class StoredCardInputViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let contentPadding: CGFloat = 16
        static let distanceFromButtonsToLabels: CGFloat = 24
        static let buttonsBottomPadding: CGFloat = 0
    }

    // MARK: - Subviews

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.distanceFromButtonsToLabels
        return stackView
    }()

    private lazy var securityCodeItemView: FormCardSecurityCodeItemView = {
        let view = FormCardSecurityCodeItemView(item: viewModel.securityCodeItem, theme: theme)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItemView")
        view.delegate = self
        return view
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var primaryButton: FormButton = {
        let button = FormButton(buttonStyle: theme.elements.buttons.primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        return button
    }()

    // MARK: - Properties

    private let viewModel: StoredCardInputViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private var theme: CheckoutTheme {
        viewModel.theme
    }

    // MARK: - Initializers

    internal init(viewModel: StoredCardInputViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        viewModel.viewDidLoad()
    }

    override internal func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assignInitialFirstResponder()
    }

    override internal func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
    }

    // MARK: - setup & configurations

    private func setupView() {
        view.backgroundColor = theme.colors.background
        view.addSubview(contentStackView)

        buttonsStackView.addArrangedSubview(primaryButton)

        [
            securityCodeItemView,
            buttonsStackView
        ].forEach(contentStackView.addArrangedSubview)

        configureConstraints()
        configureContent()
        setupBindings()
        disableSwipeDownToDismissScreen()
    }

    private func disableSwipeDownToDismissScreen() {
        isModalInPresentation = true
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.topAnchor),
            contentStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.contentPadding
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.contentPadding
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Constants.buttonsBottomPadding
            )
        ])
    }

    private func configureContent() {
        primaryButton.title = viewModel.submitButtonTitle
    }

    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            securityCodeItemView.resignFirstResponder()
        }
        primaryButton.isEnabled = !isLoading
        primaryButton.showsActivityIndicator = isLoading
        securityCodeItemView.isUserInteractionEnabled = !isLoading
    }

    private func setupBindings() {
        viewModel.inProgressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)

        viewModel.onSecurityCodeValidationRequested = { [weak self] in
            self?.securityCodeItemView.resignFirstResponder()
            // Triggers explicit validation
            self?.securityCodeItemView.showValidation()
        }
    }

    // MARK: - First responder

    /// Focuses the security code on appearance, as `FormViewController` does for its forms,
    /// so that the shopper can type without tapping the field first.
    private func assignInitialFirstResponder() {
        guard securityCodeItemView.isUserInteractionEnabled else { return }
        securityCodeItemView.becomeFirstResponder()
    }

    // MARK: - User Actions

    @objc private func primaryButtonTapped() {
        Task { @MainActor [weak self] in
            await self?.viewModel.submit()
        }
    }

}

extension StoredCardInputViewController: FormTextItemViewDelegate {
    internal func didReachMaximumLength(in itemView: FormTextItemView<some FormTextItem>) {
        securityCodeItemView.resignFirstResponder()
    }

    internal func didSelectReturnKey(in itemView: FormTextItemView<some FormTextItem>) {
        securityCodeItemView.resignFirstResponder()
    }
}
