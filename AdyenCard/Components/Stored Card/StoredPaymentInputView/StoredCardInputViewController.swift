//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

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
        static let contentPadding: CGFloat = 24
        static let distanceBetweenImageAndLabels: CGFloat = 12
        static let distanceFromButtonsToLabels: CGFloat = 24
        static let buttonsBottomPadding: CGFloat = 0

        static let secondaryButtonCornerRadius: CGFloat = 14
        static let sheetCornerRadius: CGFloat = 16

        static let labelsSpacing: CGFloat = 8
        static let buttonsSpacingWithEachOther: CGFloat = 16
    }

    // MARK: - Properties

    private let viewModel: StoredCardInputViewModelProtocol

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
    }

    // MARK: - setup & configurations

    private func setupView() {
        // TODO: Robert: Use Adyen Theme
        view.backgroundColor = .systemBackground

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
        viewModel.setPayButtonEnabled = { [weak self] enabled in
            // TODO: Robert: StoredView: disable the Pay button in this screen. Currently the UI doesn't update well. Check FormButton to include a disabled UX?
            self?.primaryButton.isEnabled = enabled
        }
        setupNavigationBackButton()
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
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Constants.buttonsBottomPadding),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.contentPadding * 2)
        ])
    }

    private func setupNavigationBackButton() {
        let backButton = UIBarButtonItem(
            // TODO: Robert: StoredView: How in the world should i get the back button here? without using the chevron.left(available iOS 13+)
            image: UIImage(systemName: "chevron.left"),
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
        primaryButton.isUserInteractionEnabled = !isLoading
        primaryButton.isEnabled = !isLoading
        primaryButton.showsActivityIndicator = isLoading
    }

    // MARK: - User Actions

    @objc private func primaryButtonTapped() {
        updateLoadingState(true)
        Task { [weak self] in
            await self?.viewModel.submitPayment()
            self?.updateLoadingState(false)
        }
    }

    @objc private func backTapped() {
        viewModel.returnToPreviousScreen()
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
        imageView.onImageLoaded = { [weak self] in
            // TODO: Robert: Do we need to do something here?
        }
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
        label.apply(viewModel.theme.elements.labels.title)
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
        let view = FormCardSecurityCodeItemView(item: viewModel.securityCodeItem, theme: viewModel.theme)
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
        let button = FormButton(buttonStyle: viewModel.theme.elements.buttons.primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.leadingImage = .adyenLock ?? .systemLock
        return button
    }()
}
