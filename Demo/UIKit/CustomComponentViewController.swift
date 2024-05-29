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
        view.distribution = .equalSpacing
        view.alignment = .top
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
        button.addTarget(self, action: #selector(performPayment), for: .touchUpInside)
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

        setupCardComponent()
        addSubviews()
        layoutViews()
        setupViews()
    }

    // MARK: - Private

    private var cardView: UIView {
        cardComponent.viewController.view
    }

    private func setupCardComponent() {
        let cardComponentViewController = cardComponent.viewController
        addChild(cardComponentViewController)
        cardComponentViewController.didMove(toParent: self)
    }

    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        [emptyViewA,
         cardView,
         payButton,
         emptyViewB].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(subView)
        }
    }

    private func layoutViews() {
        stackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Constrain UIStackView to edges of the UIScrollView
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            payButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),

            emptyViewA.heightAnchor.constraint(equalToConstant: 700),
            emptyViewA.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            emptyViewB.heightAnchor.constraint(equalToConstant: 200),
            emptyViewB.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
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

        let configuration = CardComponent.Configuration(hideDefaultPayButton: true, billingAddress: billingAddressConfiguration)
        return CardComponent(paymentMethod: paymentMethod, context: context, configuration: configuration)
    }

    @objc
    private func performPayment() {
        print("Custom payment")
        cardComponent.didSelectSubmitButton()
        stackView.layoutIfNeeded()
        view.layoutIfNeeded()
    }
}
