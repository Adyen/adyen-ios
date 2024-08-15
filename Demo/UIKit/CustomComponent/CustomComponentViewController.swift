//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenCard
import UIKit

protocol CustomComponentViewProtocol: AnyObject {
    func dismiss()
    func startActivityIndicator()
    func stopActivityIndicator()
    func present(view: UIViewController, animated: Bool)
}

class CustomComponentViewController: UIViewController, CustomComponentViewProtocol {

    private enum Content {
        static let title = "Checkout"
        static let submitButtonTitle = "Buy now"
        static let validationButtonTitle = "Validate"
    }

    // MARK: - View components

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .top
        return view
    }()

    private let topPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 8
        return view
    }()

    private let bottomPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(Content.submitButtonTitle, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(performPayment), for: .touchUpInside)
        return button
    }()

    private lazy var validityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(Content.validationButtonTitle, for: .normal)

        let coralColor = UIColor(red: 255 / 255, green: 127 / 255, blue: 80 / 255, alpha: 1.0)
        button.backgroundColor = coralColor
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(performValidation), for: .touchUpInside)
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.backgroundColor = .black
        indicator.color = .white
        indicator.layer.cornerRadius = 8
        return indicator
    }()

    // MARK: - Properties

    private let presenter: CustomComponentPresenter

    // MARK: - Initializers

    init(presenter: CustomComponentPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()

        setupCardViewController()
        addSubviews()
        layoutViews()
        setupViews()
    }

    // MARK: - CustomComponentViewProtocol

    func dismiss() {
        self.dismiss(animated: true)
    }

    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }

    func present(view: UIViewController, animated: Bool) {
        present(view, animated: animated)
    }

    // MARK: - Private

    private var cardComponentView: UIView {
        guard let cardView = presenter.cardViewController.view else {
            fatalError("Card view is nil")
        }

        return cardView
    }

    private func setupCardViewController() {
        let cardViewController = presenter.cardViewController
        addChild(cardViewController)
        cardViewController.didMove(toParent: self)
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addSubview(activityIndicator)

        [
            topPlaceholderView,
            cardComponentView,
            payButton,
            validityButton,
            bottomPlaceholderView
        ].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(subView)
        }
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            cardComponentView.widthAnchor.constraint(equalTo: stackView.widthAnchor),

            payButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            payButton.heightAnchor.constraint(equalToConstant: 48),

            validityButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            validityButton.heightAnchor.constraint(equalToConstant: 48),

            topPlaceholderView.heightAnchor.constraint(equalToConstant: 450),
            topPlaceholderView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            bottomPlaceholderView.heightAnchor.constraint(equalToConstant: 700),
            bottomPlaceholderView.widthAnchor.constraint(equalTo: stackView.widthAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40)
        ])

        stackView.bringSubviewToFront(activityIndicator)
    }

    private func setupViews() {
        view.backgroundColor = .white
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.title = Content.title
        navigationItem.largeTitleDisplayMode = .always
    }

    @objc
    private func performValidation() {
        presenter.performValidation()
    }

    @objc
    private func performPayment() {
        presenter.performPayment()
    }
}
