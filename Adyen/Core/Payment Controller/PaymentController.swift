//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// The payment controller controls the flow of a payment from start to finish.
/// This is the entry point for a custom integration, and provides you with access to all payment related information required to build your own UI.
public final class PaymentController {

    // MARK: - Initializing a Payment Controller
    
    /// Initializes the payment controller.
    ///
    /// - Parameter delegate: The delegate of the payment controller.
    public init(delegate: PaymentControllerDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        assert(!isPaymentSessionActive, "PaymentController was allocated during an active payment session.")
    }
    
    // MARK: - Accessing the Delegate
    
    /// The delegate of the payment controller.
    public private(set) weak var delegate: PaymentControllerDelegate!
    
    // MARK: - Accessing the Payment Session
    
    /// The current payment session. This value is set after a payment session is returned in the delegate's `requestPaymentSession(withToken:for: responseHandler:)`.
    public private(set) var paymentSession: PaymentSession?
    
    // MARK: - Starting and Cancelling a Payment
    
    /// Starts the payment flow.
    public func start() {
        isPaymentSessionActive = true
        start(with: PaymentSessionToken())
    }
    
    /// Cancels the payment flow.
    public func cancel() {
        finish(with: PaymentController.Error.cancelled)
    }
    
    // MARK: - Deleting Stored Payment Methods
    
    /// Deletes a stored payment method.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method to delete. This should be a payment method in the current payment session's stored payment methods array.
    ///   - completion: A closure invoked when the deletion is completed.
    public func deleteStoredPaymentMethod(_ paymentMethod: PaymentMethod, completion: @escaping Completion<Result<Void>>) {
        guard let paymentSession = paymentSession else {
            print("Cannot delete payment method. Payment session uninitialized.")
            return
        }
        
        guard let index = paymentSession.paymentMethods.preferred.index(of: paymentMethod) else {
            print("Cannot delete payment method. Payment method should be a stored payment method from the current payment session.")
            return
        }
        
        let request = StoredPaymentMethodDeletionRequest(paymentSession: paymentSession, paymentMethod: paymentMethod)
        apiClient.perform(request) { response in
            switch response {
            case .success:
                self.paymentSession?.paymentMethods.preferred.remove(at: index)
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Internal
    
    var isPaymentSessionActive = false
    
    internal func start(with token: PaymentSessionToken) {
        delegateProxy.requestPaymentSession(withToken: token.encoded, for: self) { paymentSessionBase64 in
            self.decode(paymentSessionBase64: paymentSessionBase64)
        }
    }
    
    // MARK: - Private
    
    private func decode(paymentSessionBase64: String) {
        // Base64-decode the payment session.
        guard let paymentSessionData = Data(base64Encoded: paymentSessionBase64) else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "The given string is not a valid Base64 encoded string.")
            let error = DecodingError.dataCorrupted(context)
            finish(with: error)
            
            return
        }
        
        // Decode the payment session.
        do {
            paymentSession = try Coder.decode(paymentSessionData) as PaymentSession
            filterUnavailablePaymentMethods()
            requestPaymentMethodSelection()
        } catch {
            finish(with: error)
        }
    }
    
    private func requestPaymentMethodSelection() {
        guard let paymentSession = paymentSession else {
            print("Cannot request method selection. Payment session uninitialized.")
            return
        }
        
        delegateProxy.selectPaymentMethod(from: paymentSession.paymentMethods, for: self) { [weak self] selectedPaymentMethod in
            let request = PaymentInitiationRequest(paymentSession: paymentSession, paymentMethod: selectedPaymentMethod)
            self?.initiatePayment(with: request)
        }
    }
    
    private func initiatePayment(with request: PaymentInitiationRequest) {
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                self.processPaymentInitiation(response: response, request: request)
            case let .failure(error):
                self.finish(with: error)
            }
        }
    }
    
    private func processPaymentInitiation(response: PaymentInitiationResponse, request: PaymentInitiationRequest) {
        switch response {
        case let .complete(payment):
            finish(with: payment)
        case let .redirect(redirect):
            performRedirect(redirect, for: request)
        case let .error(error):
            finish(with: error)
        }
    }
    
    private func performRedirect(_ redirect: PaymentInitiationResponse.Redirect, for request: PaymentInitiationRequest) {
        RedirectListener.registerForURL { [weak self] url in
            if redirect.shouldSubmitReturnURLQuery {
                self?.submit(returnURL: url, for: request)
            } else if let paymentResult = PaymentResult(url: url) {
                self?.finish(with: paymentResult)
            } else {
                self?.finish(with: Error.invalidReturnURL)
            }
        }
        
        delegateProxy.redirect(to: redirect.url, for: self)
    }
    
    private func submit(returnURL: URL, for request: PaymentInitiationRequest) {
        let returnURLQueryDetail = PaymentDetail(key: "returnUrlQueryString", value: returnURL.query)
        
        var request = request
        request.paymentMethod.details.append(returnURLQueryDetail)
        initiatePayment(with: request)
    }
    
    private func finish(with paymentResult: PaymentResult) {
        finish(with: .success(paymentResult))
    }
    
    private func finish(with error: Swift.Error) {
        finish(with: .failure(error))
    }
    
    private func finish(with result: Result<PaymentResult>) {
        delegateProxy.didFinish(with: result, for: self)
        isPaymentSessionActive = false
    }
    
    private lazy var apiClient = APIClient()
    
    private lazy var delegateProxy: PaymentControllerDelegateProxy = {
        PaymentControllerDelegateProxy(delegate: self.delegate)
    }()
    
    private func filterUnavailablePaymentMethods() {
        guard var paymentSession = paymentSession else {
            return
        }
        
        let pluginManager = PluginManager(paymentSession: paymentSession)
        
        func isPaymentMethodAvailable(_ paymentMethod: PaymentMethod) -> Bool {
            guard let plugin = pluginManager.plugin(for: paymentMethod) else {
                return true
            }
            
            return plugin.isDeviceSupported
        }
        
        var paymentMethods = paymentSession.paymentMethods
        paymentMethods.preferred = paymentMethods.preferred.filter(isPaymentMethodAvailable(_:))
        paymentMethods.other = paymentMethods.other.filter(isPaymentMethodAvailable(_:))
        
        self.paymentSession?.paymentMethods = paymentMethods
    }
    
}
