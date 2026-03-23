//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

internal class StoredCardInputViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let chevronBackwardImage = "chevron.backward"
        static let contentPadding: CGFloat = 24
        static let distanceBetweenImageAndLabels: CGFloat = 12
        static let distanceFromButtonsToLabels: CGFloat = 24
        static let buttonsBottomPadding: CGFloat = 0
        static let labelsSpacing: CGFloat = 8
        static let buttonsSpacingWithEachOther: CGFloat = 16
    }

    // MARK: - Subviews

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.distanceFromButtonsToLabels
        return stackView
    }()

    private lazy var topContentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.distanceBetweenImageAndLabels
        return stackView
    }()

    private lazy var cardImageView: CardImageView = {
        let imageView = CardImageView(item: viewModel.cardImageItem)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardShapedImage")
        return imageView
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.labelsSpacing
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(theme.elements.labels.title)
        label.numberOfLines = 0
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title")

        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "subTitle")
        return label
    }()

    private lazy var securityCodeItemView: FormCardSecurityCodeItemView = {
        // TODO: Robert: StoredView: 🐞 There is a bug(COSDK-572) with FormCardSecurityCodeItemView that when i type more than 3 characters only 3 display but validation happens with 4+ characters and then it fails validation. Needs to be debugged separately.
        let view = FormCardSecurityCodeItemView(item: viewModel.securityCodeItem, theme: theme)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItemView")
        return view
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.buttonsSpacingWithEachOther
        return stackView
    }()

    private lazy var primaryButton: FormButton = {
        let button = FormButton(buttonStyle: theme.elements.buttons.primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.leadingImage = .adyenLock ?? .systemLock
        return button
    }()

    // MARK: - Properties

    private let viewModel: StoredCardInputViewModelProtocol

    private var theme: AdyenTheme {
        viewModel.theme
    }

    // MARK: - Initializers

    internal init(viewModel: StoredCardInputViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupViewInstructionHandler()
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

    // MARK: - setup & configurations

    private func setupView() {
        view.backgroundColor = theme.colors.background
        // TODO: Robert: StoredView: 🐞 The scroll view isn't working in this screen. Needs separate investigation.
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(topContentStackView)
        contentStackView.addArrangedSubview(securityCodeItemView)
        contentStackView.addArrangedSubview(buttonsStackView)

        topContentStackView.addArrangedSubview(cardImageView)
        topContentStackView.addArrangedSubview(labelsStackView)

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)

        buttonsStackView.addArrangedSubview(primaryButton)

        configureConstraints()
        configureContent()
        setupNavigationBackButton()
        disableSwipeDownToDismissScreen()
    }

    private func disableSwipeDownToDismissScreen() {
        isModalInPresentation = true
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.contentPadding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.contentPadding),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.buttonsBottomPadding)
        ])
    }

    private func setupNavigationBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: Constants.chevronBackwardImage),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }

    private func configureContent() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.attributedText = viewModel.subtitleText
        primaryButton.title = viewModel.submitButtonTitle
    }

    private func updateLoadingState(_ isLoading: Bool) {
        primaryButton.isEnabled = !isLoading
        primaryButton.showsActivityIndicator = isLoading
    }

    private func setupViewInstructionHandler() {
        viewModel.onViewInstruction = { [weak self] instruction in
            guard let self else { return }
            switch instruction {
            case let .setLoading(isLoading):
                updateLoadingState(isLoading)
            case .showSecurityCodeValidation:
                securityCodeItemView.resignFirstResponder()
                securityCodeItemView.showValidation()
            }
        }
    }

    // MARK: - User Actions

    @objc private func primaryButtonTapped() {
        Task { @MainActor [weak self] in
            await self?.viewModel.submit()
        }
    }

    @objc private func backTapped() {
        viewModel.dismiss()
    }
}
