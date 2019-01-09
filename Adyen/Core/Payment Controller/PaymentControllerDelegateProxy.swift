//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A helper class that ensures the delegate is always called on the main thread.
internal class PaymentControllerDelegateProxy: PaymentControllerDelegate {
    /// The delegate to forward to.
    internal private(set) weak var delegate: PaymentControllerDelegate!
    
    /// Initializes the delegate proxy.
    ///
    /// - Parameter delegate: The delegate to forward to.
    internal init(delegate: PaymentControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - PaymentControllerDelegate
    
    func requestPaymentSession(withToken token: String, for paymentController: PaymentController, responseHandler: @escaping (String) -> Void) {
        dispatch {
            self.delegate?.requestPaymentSession(withToken: token, for: paymentController, responseHandler: responseHandler)
        }
    }
    
    func selectPaymentMethod(from paymentMethods: SectionedPaymentMethods, for paymentController: PaymentController, selectionHandler: @escaping (PaymentMethod) -> Void) {
        dispatch {
            self.delegate?.selectPaymentMethod(from: paymentMethods, for: paymentController, selectionHandler: selectionHandler)
        }
    }
    
    func redirect(to url: URL, for paymentController: PaymentController) {
        dispatch {
            self.delegate?.redirect(to: url, for: paymentController)
        }
    }
    
    func didFinish(with result: Result<PaymentResult>, for paymentController: PaymentController) {
        dispatch {
            self.delegate?.didFinish(with: result, for: paymentController)
        }
    }
    
    func provideAdditionalDetails(_ additionalDetails: AdditionalPaymentDetails, for paymentMethod: PaymentMethod, detailsHandler: @escaping Completion<[PaymentDetail]>) {
        dispatch {
            self.delegate?.provideAdditionalDetails(additionalDetails, for: paymentMethod, detailsHandler: detailsHandler)
        }
    }
    
    // MARK: - Private
    
    private func dispatch(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
    
}
