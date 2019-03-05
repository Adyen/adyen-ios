//
// Copyright (c) 2019 Adyen B.V.
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
        assert(!isPaymentSessionActive, "PaymentController was deallocated during an active payment session.")
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
        
        #if swift(>=5.0)
            let paymentMethodIndex = paymentSession.paymentMethods.preferred.firstIndex(of: paymentMethod)
        #else
            let paymentMethodIndex = paymentSession.paymentMethods.preferred.index(of: paymentMethod)
        #endif
        
        guard let index = paymentMethodIndex else {
            print("Cannot delete payment method. Payment method should be a stored payment method from the current payment session.")
            return
        }
        
        let request = StoredPaymentMethodDeletionRequest(paymentSession: paymentSession, paymentMethod: paymentMethod)
        apiClient.perform(request) { [weak self] response in
            switch response {
            case .success:
                self?.paymentSession?.paymentMethods.preferred.remove(at: index)
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Internal
    
    var isPaymentSessionActive = false
    
    internal func start(with token: PaymentSessionToken) {
        delegateProxy.requestPaymentSession(withToken: token.encoded, for: self) { [weak self] paymentSessionResponse in
            self?.decode(paymentSessionResponse: paymentSessionResponse)
        }
    }
    
    // MARK: - Private
    
    private func decode(paymentSessionResponse: String) {
        do {
            var paymentSession = try PaymentSession.decode(from: paymentSessionResponse)
            
            let pluginManager = PluginManager(paymentSession: paymentSession)
            self.pluginManager = pluginManager
            
            let availablePaymentMethods = pluginManager.availablePaymentMethods(for: paymentSession.paymentMethods)
            paymentSession.paymentMethods = availablePaymentMethods
            self.paymentSession = paymentSession
            
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
            let request = PaymentInitiationRequest(paymentSession: paymentSession,
                                                   paymentMethod: selectedPaymentMethod)
            self?.initiatePayment(with: request)
        }
    }
    
    private func initiatePayment(with request: PaymentInitiationRequest) {
        apiClient.perform(request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.processPaymentInitiation(response: response, request: request)
            case let .failure(error):
                self?.finish(with: error)
            }
        }
    }
    
    private func processPaymentInitiation(response: PaymentInitiationResponse, request: PaymentInitiationRequest) {
        switch response {
        case let .complete(payment):
            finish(with: payment)
        case let .redirect(redirect):
            performRedirect(redirect, for: request)
        case let .identify(details):
            performIdentification(with: details, for: request)
        case let .challenge(details):
            performChallenge(with: details, for: request)
        case let .error(error):
            finish(with: error)
        }
    }
    
    private func performRedirect(_ redirect: PaymentInitiationResponse.Redirect, for request: PaymentInitiationRequest) {
        RedirectListener.registerForURL { [weak self] url in
            if redirect.shouldSubmitReturnURLQuery {
                self?.submit(returnURL: url, for: request)
            } else if let paymentResult = PaymentResult(url: url, paymentMethodType: request.paymentMethod.type) {
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
        request.paymentDetails.append(returnURLQueryDetail)
        initiatePayment(with: request)
    }
    
    private func performIdentification(with details: PaymentInitiationResponse.Details, for request: PaymentInitiationRequest) {
        let identificationDetails = IdentificationPaymentDetails(details: details.paymentDetails, userInfo: details.userInfo)
        requestAdditionalDetails(identificationDetails, for: request, paymentData: details.paymentData, returnData: details.returnData)
    }
    
    private func performChallenge(with details: PaymentInitiationResponse.Details, for request: PaymentInitiationRequest) {
        let challengeDetails = ChallengePaymentDetails(details: details.paymentDetails, userInfo: details.userInfo)
        requestAdditionalDetails(challengeDetails, for: request, paymentData: details.paymentData, returnData: details.returnData)
    }
    
    private func requestAdditionalDetails(_ additionalDetails: AdditionalPaymentDetails, for request: PaymentInitiationRequest, paymentData: String?, returnData: String?) {
        let returnDataDetailsKey = "paymentMethodReturnData"
        var additionalDetails = additionalDetails
        additionalDetails.details = additionalDetails.details.filter { $0.key != returnDataDetailsKey }
        
        delegateProxy.provideAdditionalDetails(additionalDetails, for: request.paymentMethod) { [weak self] filledDetails in
            var filledDetails = filledDetails
            
            if let returnData = returnData {
                let returnDataDetail = PaymentDetail(key: returnDataDetailsKey, value: returnData)
                filledDetails.append(returnDataDetail)
            }
            
            let paymentInitiationRequest = PaymentInitiationRequest(paymentSession: request.paymentSession,
                                                                    paymentMethod: request.paymentMethod,
                                                                    paymentDetails: filledDetails,
                                                                    paymentData: paymentData)
            
            self?.initiatePayment(with: paymentInitiationRequest)
        }
    }
    
    private func finish(with paymentResult: PaymentResult) {
        finish(with: .success(paymentResult))
    }
    
    internal func finish(with error: Swift.Error) {
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
    
    // MARK: - Plugin Manager
    
    /// The plugin manager used for the payment. Available after the payment session has been loaded.
    internal var pluginManager: PluginManager?
    
}
