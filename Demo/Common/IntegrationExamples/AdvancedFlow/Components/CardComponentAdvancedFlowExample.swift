//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCheckout
import AdyenUI
import PassKit

@MainActor
internal final class CardComponentAdvancedFlowExample: InitialDataAdvancedFlowProtocol {

    internal weak var presenter: PresenterExampleProtocol?

    private var checkout: AdvancedCheckout?
    private var adyenComponent: CheckoutPaymentComponent?

    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    private lazy var asyncApiClient = ApiClientHelper.generateAsyncApiClient()

    /// comes from demo app protocol, unused on new structure
    internal var context: AdyenContext?
    
    internal var selectedTheme: ExampleAppTheme {
        ConfigurationConstants.current.themeSettings.theme
    }

    internal init() {}

    internal func start() {
        startLoading()

        Task {
            do {
                let paymentMethods = try await requestPaymentMethods(order: nil)
                let component = try await cardComponent(from: paymentMethods)
                self.adyenComponent = component
                hideLoading()
                present(component: component)
            } catch {
                hideLoading()
                handleError(error)
            }
        }
    }
    
    // MARK: - Presentation
    
    private func cardComponent(from paymentMethods: PaymentMethods) async throws
        -> CheckoutPaymentComponent {

        let configuration = try CheckoutConfiguration(
            environment: ConfigurationConstants.componentsEnvironment,
            amount: ConfigurationConstants.current.amount,
            clientKey: ConfigurationConstants.clientKey,
            analyticsConfiguration: .init(
                isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
            )
        ) {
            ConfigurationConstants.current.cardConfiguration
                .billingAddressMode(
                    .lookup(
                        onAddressLookup: { searchTerm in
                            await MapkitAddressLookupProvider().searchAsync(searchTerm)
                        }
                    )
                )
                .onBinChange { bin in
                    print("Here is the bin \(bin)")
                }
                .onBinLookup { data in
                    print("Bin lookup response \(data)")
                }
        }
        .localizationProvider(DemoLocalizationProvider())
        .theme(selectedTheme.theme)

        let checkout = try await Checkout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: self
        )
        .onSubmit { [weak self] data in
            guard let self else { return .completion(resultCode: "Error") }
            return await self.callPayments(with: data)
        }
        .onAdditionalDetails { [weak self] data in
            guard let self else { return .completion(resultCode: "Error") }
            return await self.callDetails(with: data)
        }
        .onComplete { [weak self] result in
            self?.dismissAndShowAlert(
                result.resultCode.isSuccess,
                result.resultCode.rawValue
            )
        }
        .onFailure { [weak self] error in
            self?.dismissAndShowAlert(false, error.localizedDescription)
        }

        self.checkout = checkout

        return try checkout.createPaymentComponent(for: .scheme)
    }

    // MARK: - Payment response handling

    private func callPayments(with data: PaymentComponentData) async -> SubmitResult {
        do {
            let request = PaymentsRequest(data: data)
            let response = try await asyncApiClient.performAsync(request)
            if let action = response.action {
                return .action(action)
            }
            return .completion(resultCode: response.resultCode.rawValue)
        } catch {
            return .completion(resultCode: "Error")
        }
    }

    private func callDetails(with data: ActionComponentData) async -> AdditionalDetailsResult {
        do {
            let request = PaymentDetailsRequest(
                details: data.details,
                paymentData: data.paymentData,
                merchantAccount: ConfigurationConstants.current.merchantAccount
            )
            let response = try await asyncApiClient.performAsync(request)
            return .completion(resultCode: response.resultCode.rawValue)
        } catch {
            return .completion(resultCode: "Error")
        }
    }
    
    // MARK: - Private

    private func startLoading() {
        presenter?.showLoadingIndicator()
    }

    private func handleError(_ error: Error) {
        presenter?.presentAlert(withTitle: "Error", message: error.localizedDescription)
    }

    private func hideLoading() {
        presenter?.hideLoadingIndicator()
    }

    private func present(component: CheckoutPaymentComponent) {
        presenter?.present(viewController: viewController(for: component), completion: nil)
    }

    private func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

    private func viewController(for component: CheckoutPaymentComponent) -> UIViewController {
        let navigation = UINavigationController(rootViewController: component.viewController!)
        component.viewController?.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        return navigation
    }

    @objc private func cancelPressed() {
        // TODO: component cancellation?
        //        component?.cancelIfNeeded()
        presenter?.dismiss(completion: nil)
    }

}

// MARK: - Localization Provider Examples

// Two grouping patterns for ``CheckoutLocalizationProvider``.
// Choose the one that best fits your data source.
//
// To add support for a *completely new language*, place a `.strings` or `.xcstrings` file
// with the `adyen.*` keys in your app bundle instead — no provider needed.

/// Pattern 1 (active): group by key — co-locates all locale variants for each string.
/// Natural when you maintain a small, curated list of overrides.
///
/// Keys grouped by where they show up in the card UI:
/// - field titles (always visible): `.cardNumber`, `.cardExpiryDate`, `.cardSecurityCode`, `.cardHolderName`
/// - the "save card" toggle: `.cardStorePaymentMethod`
/// - validation errors (visible when you submit bad input): `.cardNumberInvalid`, `.cardExpiryDateInvalid`, `.cardSecurityCodeInvalid`
///
/// To eyeball locale routing, change the simulator language under Settings → General → Language & Region.
private struct DemoLocalizationProvider: CheckoutLocalizationProvider {

    private let overrides: [CheckoutLocalizationKey: [String: String]] = [
        // Field titles
        .cardNumber: [
            "en": "Custom Card Number",
            "nl": "Kaartnummer (Aangepast)",
            "fr": "Numéro de carte (perso)"
        ],
        .cardExpiryDate: [
            "en": "Custom Expiry",
            "nl": "Vervaldatum (Aangepast)",
            "fr": "Expiration (perso)"
        ],
        .cardSecurityCode: [
            "en": "Custom CVC",
            "nl": "CVC (Aangepast)",
            "fr": "CVC (perso)"
        ],
        .cardHolderName: [
            "en": "Name on card",
            "nl": "Naam op kaart",
            "fr": "Nom sur la carte"
        ],
        // Save-card toggle
        .cardStorePaymentMethod: [
            "en": "Remember this card",
            "nl": "Onthoud deze kaart",
            "fr": "Mémoriser cette carte"
        ],
        // Validation errors
        .cardNumberInvalid: [
            "en": "Card number looks wrong",
            "nl": "Kaartnummer klopt niet",
            "fr": "Numéro de carte incorrect"
        ],
        .cardExpiryDateInvalid: [
            "en": "Expiry date is invalid",
            "nl": "Vervaldatum is ongeldig",
            "fr": "Date d'expiration invalide"
        ],
        .cardSecurityCodeInvalid: [
            "en": "CVC is invalid",
            "nl": "CVC is ongeldig",
            "fr": "CVC invalide"
        ]
    ]

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        guard let languageCode = locale.languageCode else { return nil }
        let value = overrides[key]?[languageCode]
        // Debug aid for manual testing: every key the SDK asks for shows up in the console,
        // and you can see whether this provider produced an override or fell through.
        print("[DemoLocalizationProvider] key=\(key) locale=\(locale.identifier) -> \(value ?? "<fallback>")")
        return value
    }
}

/// Pattern 2: group by locale — co-locates all keys for each language.
/// Natural when you fetch a full locale bundle from a remote config system.
private struct DemoLocaleGroupedProvider: CheckoutLocalizationProvider {

    private let overrides: [String: [CheckoutLocalizationKey: String]] = [
        "en": [
            .cardNumber: "Custom Card Number",
            .cardExpiryDate: "Custom Expiry",
            .cardSecurityCode: "Custom CVC",
            .cardHolderName: "Name on card",
            .cardStorePaymentMethod: "Remember this card",
            .cardNumberInvalid: "Card number looks wrong",
            .cardExpiryDateInvalid: "Expiry date is invalid",
            .cardSecurityCodeInvalid: "CVC is invalid"
        ],
        "nl": [
            .cardNumber: "Kaartnummer (Aangepast)",
            .cardExpiryDate: "Vervaldatum (Aangepast)",
            .cardSecurityCode: "CVC (Aangepast)",
            .cardHolderName: "Naam op kaart",
            .cardStorePaymentMethod: "Onthoud deze kaart",
            .cardNumberInvalid: "Kaartnummer klopt niet",
            .cardExpiryDateInvalid: "Vervaldatum is ongeldig",
            .cardSecurityCodeInvalid: "CVC is ongeldig"
        ],
        "fr": [
            .cardNumber: "Numéro de carte (perso)",
            .cardExpiryDate: "Expiration (perso)",
            .cardSecurityCode: "CVC (perso)",
            .cardHolderName: "Nom sur la carte",
            .cardStorePaymentMethod: "Mémoriser cette carte",
            .cardNumberInvalid: "Numéro de carte incorrect",
            .cardExpiryDateInvalid: "Date d'expiration invalide",
            .cardSecurityCodeInvalid: "CVC invalide"
        ]
    ]

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        guard let languageCode = locale.languageCode else { return nil }
        return overrides[languageCode]?[key]
    }
}

extension CardComponentAdvancedFlowExample: PresentationDelegate {
   
    func present(component: any PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }
}
