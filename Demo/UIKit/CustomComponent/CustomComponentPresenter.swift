//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

protocol CustomComponentPresenterProtocol {}

class CustomComponentPresenter: CustomComponentPresenterProtocol {

    // MARK: - Properties

    weak var view: CustomComponentViewProtocol?
    private let apiClient: APIClientProtocol

    // MARK: - Initializers

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    // MARK: - Public

    // MARK: - Private

    private func performPayment(with data: PaymentComponentData,
                                from component: PaymentComponent) {
        view?.startActivityIndicator()

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            let request = PaymentsRequest(data: data)
            self.apiClient.perform(request) { [weak self] result in
                switch result {
                case let .success(response):
                    self?.handlePayment(response: response)
                case let .failure(error):
                    self?.handlePayment(error: error)
                }

                self?.view?.stopActivityIndicator()
            }
        }
    }

    private func handlePayment(response: PaymentsResponse) {
        switch response.resultCode {
        case .authorised:
            view?.dismiss()
        case .refused, .error:
            handlePayment(error: nil)
        default:
            print(response.resultCode)
        }
    }
}

extension CustomComponentPresenter: PaymentComponentDelegate {

    func didSubmit(_ data: Adyen.PaymentComponentData,
                   from component: any Adyen.PaymentComponent) {
        performPayment(with: data, from: component)
    }
    
    func didFail(with error: any Error,
                 from component: any Adyen.PaymentComponent) {
        handlePayment(error: error)

    }

    // MARK: - Private

    private func handlePayment(error: Error?) {
        let alertViewController = UIAlertController(title: "Payment failed",
                                                    message: "There was error processing the payment. \(error?.localizedDescription ?? "")",
                                                    preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            alertViewController.dismiss(animated: true)
        }
        alertViewController.addAction(doneAction)
        (view as? UIViewController)?.present(alertViewController, animated: true)
    }
}
