//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

internal class StoredPaymentComponentViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let contentPadding: CGFloat = 24
        static let distanceBetweenImageAndLabels: CGFloat = 12
        static let labelsSpacing: CGFloat = 8
    }

    // MARK: - Properties

    private let viewModel: StoredPaymentComponentViewModelProtocol

    private var theme: CheckoutTheme {
        viewModel.theme
    }

    // MARK: - Initializers

    internal init(viewModel: StoredPaymentComponentViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupLoadingStateHandler()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
        viewModel.viewDidLoad()
    }

    // MARK: - setup & configurations

    private func setupView() {
        view.backgroundColor = theme.colors.background

        view.addSubview(scrollView)
        view.addSubview(primaryButton)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(topContentStackView)

        topContentStackView.addArrangedSubview(cardImageView)
        topContentStackView.addArrangedSubview(labelsStackView)

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)

        configureConstraints()
        configureContent()
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -Constants.contentPadding),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.contentPadding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Constants.contentPadding),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -Constants.contentPadding * 2),

            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.contentPadding),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.contentPadding),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.contentPadding)
        ])
    }

    private func configureContent() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        primaryButton.title = viewModel.submitButtonTitle
    }

    private func setupNavigationItem() {
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.leftBarButtonItem = cancelButton
    }

    private func setupLoadingStateHandler() {
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }
    }

    private func updateLoadingState(_ isLoading: Bool) {
        primaryButton.showsActivityIndicator = isLoading
    }

    // MARK: - User Actions

    @objc private func cancelTapped() {
        viewModel.cancel()
    }

    @objc private func primaryButtonTapped() {
        viewModel.submitPayment()
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
        label.apply(theme.elements.labels.body)
        label.numberOfLines = 0
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "subTitle")
        return label
    }()

    private lazy var primaryButton: FormButton = {
        let button = FormButton(buttonStyle: theme.elements.buttons.primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "primaryButton")
        button.leadingImage = .adyenLock ?? .systemLock
        return button
    }()
}
