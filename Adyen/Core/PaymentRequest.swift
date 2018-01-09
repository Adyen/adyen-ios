//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public typealias DataCompletion = (Data) -> Void
public typealias MethodCompletion = (PaymentMethod) -> Void
public typealias URLCompletion = (URL) -> Void
public typealias CardScanCompletion = ((number: String?, expiryDate: String?, cvc: String?)) -> Void
public typealias PaymentDetailsCompletion = (PaymentDetails) -> Void

/// The starting point for [Custom Integration](https://docs.adyen.com/developers/payments/accepting-payments/in-app-integration).
public final class PaymentRequest {
    
    // MARK: - Initializing
    
    /**
     Creates a `PaymentRequest` object and initialises it with a provided delegate.
     - parameter delegate: An object that implements `PaymentRequestDelegate`.
     - returns: An initialised instance of the payment request.
     */
    public init(delegate: PaymentRequestDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Accessing Delegate
    
    /// Delegate for controlling the payment flow. See `PaymentRequestDelegate`.
    internal(set) public weak var delegate: PaymentRequestDelegate?
    
    // MARK: - Accessing Payment Information
    
    /// The selected payment method.
    private(set) public var paymentMethod: PaymentMethod?
    
    /// Amount to be charged.
    private(set) public var amount: Int?
    
    /// Payment currency.
    private(set) public var currency: String?
    
    /// Payment reference.
    private(set) public var reference: String?
    
    /// Payment country code.
    private(set) public var countryCode: String?
    
    /// Shopper locale.
    private(set) public var shopperLocale: String?
    
    /// Shopper reference.
    private(set) public var shopperReference: String?
    
    /// Generation time. Used for generating a token for card payments.
    private(set) public var generationTime: String?
    
    /// Public key. Used for generating a token for card payments.
    private(set) public var publicKey: String?
    
    // MARK: - Performing Payment Request Actions
    
    /// The token that is sent with a setup request.
    internal var token = PaymentRequestToken()
    
    /// Starts the payment request.
    public func start() {
        requestPaymentData(forToken: token.encoded)
    }
    
    /// Permanently deletes payment method from shopper's preferred payment options.
    public func deletePreferred(paymentMethod: PaymentMethod, completion: @escaping (Bool, Error?) -> Void) {
        guard let paymentServer = paymentServer,
            let preferredMethods = preferredMethods,
            preferredMethods.contains(paymentMethod) else {
            completion(false, .unexpectedError)
            return
        }
        
        paymentServer.deletePreferredPaymentMethod(paymentMethod) { [weak self] responseInfo, error in
            guard let responseInfo = responseInfo,
                let resultCode = responseInfo["resultCode"] as? String, resultCode == "Success" else {
                completion(false, .unexpectedError)
                return
            }
            
            //  Remove payment method from the list if deletion succeeded.
            if let index = preferredMethods.index(of: paymentMethod) {
                self?.preferredMethods?.remove(at: index)
            }
            
            DispatchQueue.main.async {
                completion(true, error)
            }
            
            //  Update list on completion.
            self?.requestPaymentMethodSelection(fromPreferred: self?.preferredMethods, available: self?.availableMethods ?? [])
        }
    }
    
    /// Cancels the payment request.
    public func cancel() {
        finish(with: .error(.cancelled))
    }
    
    // MARK: - Private
    
    private(set) internal var paymentSetup: PaymentSetup?
    private var preferredMethods: [PaymentMethod]?
    private var availableMethods: [PaymentMethod]?
    
    private lazy var paymentServer: PaymentServer? = {
        guard let paymentSetup = self.paymentSetup else {
            return nil
        }
        
        return PaymentServer(paymentSetup: paymentSetup)
    }()
    
    private(set) internal lazy var pluginManager: PluginManager? = {
        guard let paymentSetup = self.paymentSetup else {
            return nil
        }
        
        return PluginManager(paymentSetup: paymentSetup)
    }()
    
    private var finalStatePlugin: PluginRequiresFinalState? {
        guard let paymentMethod = paymentMethod else {
            return nil
        }
        
        return pluginManager?.plugin(for: paymentMethod) as? PluginRequiresFinalState
    }
    
    private func process(_ paymentSetup: PaymentSetup) {
        func isPaymentMethodAvailable(_ paymentMethod: PaymentMethod) -> Bool {
            if paymentMethod.requiresPlugin {
                guard let plugin = pluginManager?.plugin(for: paymentMethod) else {
                    return false
                }
                
                if let deviceDependablePlugin = plugin as? DeviceDependablePlugin {
                    return deviceDependablePlugin.isDeviceSupported
                }
            }
            
            return true
        }
        
        self.paymentSetup = paymentSetup
        
        let preferredMethods = paymentSetup.preferredPaymentMethods.filter(isPaymentMethodAvailable(_:))
        self.preferredMethods = preferredMethods
        
        let availableMethods = paymentSetup.availablePaymentMethods.filter(isPaymentMethodAvailable(_:))
        self.availableMethods = availableMethods
        
        // Suggest available payment methods.
        self.requestPaymentMethodSelection(fromPreferred: preferredMethods, available: availableMethods)
    }
    
    private func processPayment(with method: PaymentMethod, additionalRequiredFields: [String: Any]? = nil) {
        if let additionalRequiredFields = additionalRequiredFields {
            method.providedAdditionalRequiredFields = additionalRequiredFields
        }
        
        paymentMethod = method
        
        guard !method.requiresPaymentDetails() else {
            requestPaymentDetails()
            return
        }
        
        guard let paymentServer = paymentServer else {
            paymentProcessingFailed(with: .unexpectedError)
            return
        }
        
        paymentServer.initiatePayment(for: method) { [weak self] paymentInitiation, error in
            guard let paymentInitiation = paymentInitiation, error == nil else {
                self?.paymentProcessingFailed(with: error)
                return
            }
            
            // If we've received fresh fallback return data from the initiate call, then set it.
            // Otherwise leave it as is, so not to nullify existing data.
            if let initialReturnData = paymentInitiation.initialReturnData {
                method.fallbackReturnData = initialReturnData
            }
            
            switch paymentInitiation.state {
            case let .redirect(url, shouldSubmitRedirectData):
                self?.requestRedirectURL(from: url, submitRedirectData: shouldSubmitRedirectData)
            case let .completed(status, payload):
                self?.completePaymentFlow(using: ["resultCode": status.rawValue, "payload": payload])
            case let .error(error):
                self?.paymentProcessingFailed(with: error)
            }
        }
    }
    
    private func requestPaymentDetails() {
        guard let paymentMethod = paymentMethod, let inputDetails = paymentMethod.inputDetails, paymentSetup != nil else {
            paymentProcessingFailed(with: .unexpectedError)
            return
        }
        
        let paymentDetails = PaymentDetails(details: inputDetails)
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, requiresPaymentDetails: paymentDetails, completion: { [weak self] fulfilledDetails in
                paymentMethod.fulfilledPaymentDetails = fulfilledDetails
                self?.processPayment(with: paymentMethod)
            })
        }
    }
    
    private func paymentProcessingFailed(with error: Error?) {
        func finishWithError() {
            let finalError = error ?? .unexpectedError
            finish(with: .error(finalError))
        }
        
        if let plugin = finalStatePlugin {
            plugin.finish(with: .error, completion: {
                finishWithError()
            })
        } else {
            finishWithError()
        }
    }
    
    private func paymentProcessingFinished(with payment: Payment) {
        func finishWithPayment() {
            finish(with: .payment(payment))
        }
        
        if let plugin = finalStatePlugin {
            plugin.finish(with: payment.status, completion: {
                finishWithPayment()
            })
        } else {
            finishWithPayment()
        }
    }
    
    private func continueRedirectPaymentFlow(with appUrl: URL, submitRedirectData: Bool) {
        if submitRedirectData, let query = appUrl.query, let paymentMethod = paymentMethod {
            let additionalRequiredFields = ["paymentMethodReturnData": query]
            processPayment(with: paymentMethod, additionalRequiredFields: additionalRequiredFields)
        } else {
            completePaymentFlow(using: appUrl.queryParameters())
        }
    }
    
    private func completePaymentFlow(using info: [String: Any]?) {
        guard let resultCode = info?["resultCode"] as? String,
            let status = PaymentStatus(rawValue: resultCode),
            let payload = info?["payload"] as? String,
            let paymentSetup = paymentSetup else {
            paymentProcessingFailed(with: .unexpectedData)
            return
        }
        
        let result = Payment(status: status, method: paymentMethod!, payload: payload, paymentSetup: paymentSetup)
        paymentProcessingFinished(with: result)
    }
    
    private func requestPaymentData(forToken token: String) {
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, requiresPaymentDataForToken: token, completion: { [weak self] data in
                guard let paymentSetup = PaymentSetup(data: data) else {
                    self?.paymentProcessingFailed(with: .unexpectedData)
                    return
                }
                
                //  Public properties
                self?.amount = paymentSetup.amount
                self?.currency = paymentSetup.currencyCode
                self?.reference = paymentSetup.merchantReference
                self?.countryCode = paymentSetup.countryCode
                self?.shopperLocale = paymentSetup.shopperLocaleIdentifier
                self?.shopperReference = paymentSetup.shopperReference
                self?.publicKey = paymentSetup.publicKey
                self?.generationTime = paymentSetup.generationDateString
                
                self?.process(paymentSetup)
            })
        }
    }
    
    private func requestPaymentMethodSelection(fromPreferred preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod]) {
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, requiresPaymentMethodFrom: preferredMethods, available: availableMethods, completion: { [weak self] method in
                self?.processPayment(with: method)
            })
        }
    }
    
    private func requestRedirectURL(from url: URL, submitRedirectData: Bool) {
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, requiresReturnURLFrom: url, completion: { [weak self] url in
                self?.continueRedirectPaymentFlow(with: url, submitRedirectData: submitRedirectData)
            })
        }
    }
    
    private func finish(with result: PaymentRequestResult) {
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, didFinishWith: result)
        }
    }
}
