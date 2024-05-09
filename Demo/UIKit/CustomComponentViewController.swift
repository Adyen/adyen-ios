//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@testable import AdyenCard
import UIKit

class CustomComponentViewController: UIViewController {

    // MARK: - View components

    private var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Pay now", for: .normal)
        button.backgroundColor = .black
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

        [cardView, payButton].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }
    }

    private func layoutViews() {
        guard let securedViewController = cardComponent.viewController as? SecuredViewController<CardViewController> else {
            fatalError("No FormViewController")
        }

        addChild(securedViewController)
        securedViewController.didMove(toParent: self)

        let cardView = securedViewController.view!

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            payButton.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupViews() {
        view.backgroundColor = UIColor(red: 204 / 255, green: 78 / 255, blue: 59 / 255, alpha: 1.0)

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Checkout"
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
