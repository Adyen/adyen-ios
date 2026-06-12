//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenComponents
import AdyenSession

@MainActor
internal final class IssuerListComponentExample: InitialDataFlowProtocol {

    // MARK: - Properties

    internal var session: Session?
    internal weak var presenter: PresenterExampleProtocol?
    internal var issuerListComponent: IssuerListComponent?
    
    internal lazy var apiClient = ApiClientHelper.generateApiClient()
    
    internal var context: AdyenContext?

    // MARK: - Initializers

    internal init() {}

    internal func start() {
        presenter?.showLoadingIndicator()
        Task {
            do {
                try await initializeExampleAppAdyenContext()
                loadSession { [weak self] response in
                    guard let self else { return }

                    self.presenter?.hideLoadingIndicator()

                    switch response {
                    case let .success(session):
                        self.session = session
                        self.presentComponent(with: session)

                    case let .failure(error):
                        self.presentAlert(with: error)
                    }
                }
            } catch {
                self.presenter?.hideLoadingIndicator()
                self.presentAlert(with: error)
            }

        }
    }

    // MARK: - Networking

    internal func loadSession(completion: @escaping (Result<Session, Error>) -> Void) {
        requestSessionInitialInfo { [weak self] response in
            guard let self else { return }
            switch response {
            case let .success(model):
//                AdyenSession.initialize(
//                    with: configuration,
//                    delegate: self,
//                    presentationDelegate: self,
//                    completion: completion
//                )
                break
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Presentation

    internal func presentComponent(with session: Session) {
        do {
            let component = try issuerListComponent(from: session)
            let componentViewController = viewController(for: component)
            presenter?.present(viewController: componentViewController, completion: nil)
            issuerListComponent = component
        } catch {
            self.presentAlert(with: error)
        }
    }

    private func issuerListComponent(from session: Session) throws -> IssuerListComponent {
        let paymentMethods = session.state.paymentMethods
        guard let paymentMethod = paymentMethods.paymentMethod(ofType: IssuerListPaymentMethod.self) else {
            throw IntegrationError.paymentMethodNotAvailable(paymentMethod: IssuerListPaymentMethod.self)
        }
        guard let context else {
            fatalError("AdyenContext is not initialized")
        }

        return IssuerListComponent(paymentMethod: paymentMethod, context: context)
        // TODO: Migrate to Checkout — Session no longer conforms to PaymentComponentDelegate in v6.
        // component.delegate = session
    }

    private func present(_ component: PresentableComponent) {
        presenter?.present(viewController: component.viewController, completion: nil)
    }

    // MARK: - Alert handling

    internal func presentAlert(with error: Error, retryHandler: (() -> Void)? = nil) {
        presenter?.presentAlert(with: error, retryHandler: retryHandler)
    }

    internal func dismissAndShowAlert(_ success: Bool, _ message: String) {
        presenter?.dismiss {
            // Payment is processed. Add your code here.
            let title = success ? "Success" : "Error"
            self.presenter?.presentAlert(withTitle: title, message: message)
        }
    }

}

// TODO: Migrate to Checkout API — SessionDelegate has been removed in v6.

extension IssuerListComponentExample: PresentationDelegate {
    internal func present(viewController: UIViewController) {
        presenter?.present(viewController: viewController, completion: nil)
    }
}

private extension IssuerListComponentExample {
    
    func viewController(for component: PresentableComponent) -> UIViewController {
        let viewController = component.viewController
        let navigation = UINavigationController(rootViewController: viewController)
        viewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelPressed)
        )
        return navigation
    }
    
    @objc private func cancelPressed() {
        issuerListComponent?.cancel()
        presenter?.dismiss(completion: nil)
    }
}
