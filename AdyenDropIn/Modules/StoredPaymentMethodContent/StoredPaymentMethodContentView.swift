//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
#if canImport(AdyenUI)
    import AdyenUI
#endif
import SwiftUI

internal struct StoredPaymentMethodContentView: View {

    private enum Constants {
        static let contentPadding: CGFloat = 24
    }

    private static let accessibilityID = "storedPaymentMethodContent.screen"

    private let viewModel: StoredPaymentMethodContentViewModel

    internal init(viewModel: StoredPaymentMethodContentViewModel) {
        self.viewModel = viewModel
    }

    internal var body: some View {
        VStack {
            // TODO: Robert: How do I center this in SwiftUI? Without using any computations using GeometryReaders or Layout. A problem for later.
            StoredPaymentMethodContentHeaderView(
                logoURL: viewModel.paymentMethodLogoURL,
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                theme: viewModel.theme
            )
            .padding(.horizontal, Constants.contentPadding)

            ComponentViewControllerView(viewController: viewModel.componentViewController)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: viewModel.theme.colors.background))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .accessibilityIdentifier(Self.accessibilityID)
    }

    private var backButton: some View {
        Button {
            viewModel.cancel()
        } label: {
            Image(systemName: "chevron.backward")
        }
    }
}

private struct ComponentViewControllerView: UIViewControllerRepresentable {

    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Previews

#if DEBUG
    #Preview("Stored card security code") {
        NavigationStack {
            StoredPaymentMethodContentView(
                viewModel: StoredPaymentMethodContentPreviewFactory.makeStoredCardViewModel()
            )
        }
    }

    #Preview("Stored ACH Direct Debit") {
        NavigationStack {
            StoredPaymentMethodContentView(
                viewModel: StoredPaymentMethodContentPreviewFactory.makeStoredACHViewModel()
            )
        }
    }

    @MainActor
    private enum StoredPaymentMethodContentPreviewFactory {

        static func makeStoredCardViewModel() -> StoredPaymentMethodContentViewModel {
            guard let paymentMethod: StoredCardPaymentMethod = try? AdyenCoder.decode(
                """
                {
                  "type": "scheme",
                  "name": "Visa",
                  "id": "stored-card",
                  "brand": "visa",
                  "lastFour": "1111",
                  "expiryMonth": "03",
                  "expiryYear": "2030",
                  "supportedShopperInteractions": ["Ecommerce"]
                }
                """
            ) else {
                preconditionFailure("Invalid stored card preview fixture")
            }
            let component = StoredCardSecurityCodeComponent(
                storedCardPaymentMethod: paymentMethod,
                context: context,
                theme: .default
            )
            return makeViewModel(component: component)
        }

        static func makeStoredACHViewModel() -> StoredPaymentMethodContentViewModel {
            guard let paymentMethod: StoredACHDirectDebitPaymentMethod = try? AdyenCoder.decode(
                """
                {
                  "type": "ach",
                  "name": "ACH Direct Debit",
                  "id": "stored-ach",
                  "bankAccountNumber": "123456789",
                  "supportedShopperInteractions": ["Ecommerce"]
                }
                """
            ) else {
                preconditionFailure("Invalid stored ACH preview fixture")
            }
            let component = StoredPaymentMethodComponent(
                paymentMethod: paymentMethod,
                context: context
            )
            return makeViewModel(component: component)
        }

        private static var context: AdyenContext {
            guard let apiContext = try? APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING") else {
                preconditionFailure("Invalid preview API context")
            }
            return AdyenContext(
                apiContext: apiContext,
                amount: Amount(value: 1000, currencyCode: "EUR"),
                publicKey: "preview",
                checkoutAttemptId: nil,
                analyticsAPIContext: nil
            )
        }

        private static func makeViewModel(
            component: any StoredPaymentComponent
        ) -> StoredPaymentMethodContentViewModel {
            StoredPaymentMethodContentViewModel(
                component: component,
                theme: .default,
                logoURLProvider: LogoURLProvider(environment: Environment.test),
                localizationParameters: nil,
                dropInFlowManager: PreviewFlowManager()
            )
        }
    }

    @MainActor
    private final class PreviewFlowManager: DropInFlowManaging {

        func submit(
            _ data: PaymentComponentData,
            from component: PaymentComponent,
            actionPresenter: ActionPresenter
        ) {}

        func fail(with error: Error, from component: PaymentComponent) {}

        func cancel(component: PaymentComponent) {}

        func handle(action: Action) {}
    }
#endif
