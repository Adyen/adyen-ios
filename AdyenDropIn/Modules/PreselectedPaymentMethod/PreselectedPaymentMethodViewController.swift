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

internal class PreselectedPaymentMethodViewController: UIViewController {

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

    private let viewModel: PreselectedPaymentMethodViewModelProtocol

    // MARK: - Initializers

    internal init(viewModel: PreselectedPaymentMethodViewModelProtocol) {
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
        configurePresentationSheet()
        viewModel.viewDidLoad()
    }

    // MARK: - setup & configurations

    private func setupView() {
        // TODO: Robert: Use Adyen Theme
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(topContentStackView)
        contentStackView.addArrangedSubview(buttonsStackView)

        topContentStackView.addArrangedSubview(cardImageView)
        topContentStackView.addArrangedSubview(labelsStackView)

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)

        buttonsStackView.addArrangedSubview(primaryButton)
        buttonsStackView.addArrangedSubview(secondaryButton)

        configureConstraints()
        configureContent()
    }

    /// Two tasks,
    /// 1. Avoid swipe down to dismiss.
    /// 2. to make the screen dynamic sizable.
    private func configurePresentationSheet() {
        // Adding this to avoid swiping down to dimiss the controller.
        isModalInPresentation = true

        // Adding this to make the controller fit its content height.
        // TODO: Robert: Need to see if there a solution for iOS15 and lesser. But if not maybe just use full screen for below iOS 15 not much traffic there anyway. I would address lower OS's as a separate task.
        // iOS 16+: Custom detent to fit content exactly This works really well.
        // iOS 15 & lower - using full screen. From my initial check this gets a bit complicated.
        if #available(iOS 16.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [
                    .custom { [weak self] _ in
                        self?.calculateContentHeight()
                    }
                ]
                sheet.prefersGrabberVisible = false
                sheet.preferredCornerRadius = Constants.sheetCornerRadius
            }
        }
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

    private func configureContent() {
        titleLabel.text = viewModel.titleText
        subtitleLabel.text = viewModel.subtitleText
        primaryButton.title = viewModel.submitButtonTitle
        secondaryButton.title = viewModel.showAllPaymentMethodsButtonTitle
    }

    private func setupNavigationItem() {
        setupCancelButton()
    }

    private func setupCancelButton() {
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
        secondaryButton.isEnabled = !isLoading
    }

    // MARK: - User Actions

    @objc private func cancelTapped() {
        viewModel.cancel()
    }

    @objc private func primaryButtonTapped() {
        viewModel.submitPayment()
    }

    @objc private func secondaryButtonTapped() {
        viewModel.showAllPaymentMethods()
    }

    // MARK: - Subviews

    /// In order to present the controller to adjust to the height of the content. We calculate the height of the content + the buttons.
    private func calculateContentHeight() -> CGFloat {
        view.layoutIfNeeded()
        let topContentHeight = topContentStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height
        let buttonsHeight = buttonsStackView
            .systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            .height
        return topContentHeight
            + buttonsHeight
            + Constants.distanceBetweenImageAndLabels
            + Constants.distanceFromButtonsToLabels
            + Constants.buttonsBottomPadding
            + view.safeAreaInsets.top
    }

    /// Call this when any subview resizes itself.
    /// That will allow this screen to redraw and then we can compute the dynamic heigh tof the screen.
    private func invalidateSheetDetent() {
        if #available(iOS 16.0, *) {
            sheetPresentationController?.invalidateDetents()
        }
    }

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
            self?.invalidateSheetDetent()
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
        label.apply(viewModel.theme.elements.labels.body)
        label.numberOfLines = 0
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "subTitle")
        return label
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

    private lazy var secondaryButton: FormButton = {
        let button = FormButton(buttonStyle: viewModel.theme.elements.buttons.secondary)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "secondaryButton")
        return button
    }()
}
