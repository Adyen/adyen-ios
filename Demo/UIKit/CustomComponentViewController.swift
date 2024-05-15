//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenCard
import UIKit

class CustomComponentViewController: UIViewController {

    private enum Colors {
        static var terracota = UIColor(red: 204 / 255, green: 78 / 255, blue: 59 / 255, alpha: 1.0)
    }

    // MARK: - View components

    private let scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = true
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        return view
    }()

    private let emptyViewA: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        return view
    }()

    private let emptyViewB: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()

    private let payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Buy now", for: .normal)
        button.backgroundColor = Colors.terracota
        button.layer.cornerRadius = 8.0
        return button
    }()

    // MARK: - Properties

    private let cardComponent: CardComponent

    // MARK: - Initializers

    init() {
        self.cardComponent = Self.resolveCardComponent()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        addSubviews()
        layoutViews()
        setupViews()
    }

    // MARK: - Private

    private func addSubviews() {
        guard let securedViewController = cardComponent.viewController as? SecuredViewController<CardViewController> else {
            fatalError("No FormViewController")
        }

        addChild(securedViewController)
        securedViewController.didMove(toParent: self)

        let cardView = securedViewController.view!

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        [emptyViewA, cardView, payButton, emptyViewB, emptyViewB].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(subView)
        }
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])

        guard let securedViewController = cardComponent.viewController as? SecuredViewController<CardViewController> else {
            fatalError("No FormViewController")
        }

        addChild(securedViewController)
        securedViewController.didMove(toParent: self)

        let cardView = securedViewController.view!

        NSLayoutConstraint.activate([
            //            emptyView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            emptyView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            emptyView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emptyViewA.heightAnchor.constraint(equalToConstant: 700),
            emptyViewB.heightAnchor.constraint(equalToConstant: 200)
        ])

//        NSLayoutConstraint.activate([
//            cardView.topAnchor.constraint(equalTo: emptyView.bottomAnchor),
//            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//
//        NSLayoutConstraint.activate([
//            payButton.topAnchor.constraint(equalTo: cardView.bottomAnchor),
//            payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            payButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
    }

    private func setupViews() {
        view.backgroundColor = .white
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Checkout"
        navigationItem.largeTitleDisplayMode = .always
    }

    private static func resolveCardComponent() -> CardComponent {
        let apiContext = ConfigurationConstants.apiContext
        let context = AdyenContext(apiContext: apiContext, payment: nil)
        let paymentMethod = CardPaymentMethod(type: .scheme,
                                              name: "Card",
                                              fundingSource: .debit,
                                              brands: [.visa])
        var billingAddressConfiguration = BillingAddressConfiguration()
        billingAddressConfiguration.mode = .full
        return CardComponent(paymentMethod: paymentMethod, context: context, configuration: .init(billingAddress: billingAddressConfiguration))
    }
}
