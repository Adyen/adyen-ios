//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let deviceFingerprintVersion = "1.0"

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
    
    /// Starts the payment request.
    public func start() {
        let token = paymentToken
        
        requestPaymentData(forToken: token) { data in
            guard let paymentSetup = PaymentSetup(data: data) else {
                self.paymentProcessingFailed(with: .unexpectedData)
                return
            }
            
            //  Public properties
            self.amount = paymentSetup.amount
            self.currency = paymentSetup.currencyCode
            self.reference = paymentSetup.merchantReference
            self.countryCode = paymentSetup.countryCode
            self.shopperLocale = paymentSetup.shopperLocaleIdentifier
            self.shopperReference = paymentSetup.shopperReference
            self.publicKey = paymentSetup.publicKey
            self.generationTime = paymentSetup.generationDateString
            
            self.process(paymentSetup)
        }
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
            self?.requestPaymentMethodSelection(fromPreferred: self?.preferredMethods, available: self?.availableMethods ?? [], completion: { method in
                self?.processPayment(with: method)
            })
        }
    }
    
    /// Cancels the payment request.
    public func cancel() {
        finish(with: .error(.cancelled))
    }
    
    // MARK: - Private
    
    private var paymentToken: String {
        let fingerprintInfo = [
            "deviceFingerprintVersion": deviceFingerprintVersion,
            "platform": "ios",
            "osVersion": UIDevice.current.systemVersion,
            "sdkVersion": sdkVersion,
            "locale": NSLocale.current.identifier,
            "deviceIdentifier": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "apiVersion": "4"
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: fingerprintInfo, options: []) {
            return data.base64EncodedString()
        } else {
            return ""
        }
    }
    
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
    
    private var delegateQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    private func isPaymentMethodAvailable(_ paymentMethod: PaymentMethod) -> Bool {
        guard paymentMethod.requiresPlugin else {
            return true
        }
        
        guard let plugin = pluginManager?.plugin(for: paymentMethod) else {
            return false
        }
        
        guard let deviceDependablePlugin = plugin as? DeviceDependablePlugin else {
            return true
        }
        
        return deviceDependablePlugin.isDeviceSupported
    }
    
    private func process(_ paymentSetup: PaymentSetup) {
        self.paymentSetup = paymentSetup
        
        let preferredMethods = paymentSetup.preferredPaymentMethods.filter(isPaymentMethodAvailable(_:))
        self.preferredMethods = preferredMethods
        
        let availableMethods = paymentSetup.availablePaymentMethods.filter(isPaymentMethodAvailable(_:))
        self.availableMethods = availableMethods
        
        //  Suggest available payment methods.
        self.requestPaymentMethodSelection(fromPreferred: preferredMethods, available: availableMethods) { [weak self] selectedMethod in
            //  Next Step. Selected payment method.
            //  Continue with Payment Data / Authorize URL.
            self?.processPayment(with: selectedMethod)
        }
    }
    
    private func processPayment(with method: PaymentMethod) {
        paymentMethod = method
        
        if method.requiresPaymentDetails() {
            requestPaymentDetails()
        } else {
            continuePaymentFlow()
        }
    }
    
    private func continuePaymentFlow() {
        guard let paymentServer = paymentServer, let paymentMethod = paymentMethod else {
            paymentProcessingFailed(with: .unexpectedError)
            return
        }
        
        paymentServer.initiatePayment(for: paymentMethod) { [weak self] paymentInitiation, error in
            guard let paymentInitiation = paymentInitiation, error == nil else {
                self?.paymentProcessingFailed(with: error)
                return
            }
            
            switch paymentInitiation.state {
            case let .redirect(url):
                self?.requestRedirectURL(from: url) { url in
                    self?.continueRedirectPaymentFlow(with: url)
                }
            case let .completed(status, payload):
                self?.completePaymentFlow(using: [
                    "resultCode": status.rawValue,
                    "payload": payload
                ])
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
        delegateQueue.async {
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
    
    private func continueRedirectPaymentFlow(with appUrl: URL) {
        guard paymentMethod?.additionalRequiredFields == nil else {
            // Different flow, reinitiate with new query parameters.
            paymentMethod?.providedAdditionalRequiredFields = appUrl.queryParameters()
            continuePaymentFlow()
            return
        }
        
        completePaymentFlow(using: appUrl.queryParameters())
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
    
    private func requestPaymentData(forToken token: String, completion: @escaping DataCompletion) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, requiresPaymentDataForToken: token, completion: completion)
        }
    }
    
    private func requestPaymentMethodSelection(fromPreferred preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, requiresPaymentMethodFrom: preferredMethods, available: availableMethods, completion: completion)
        }
    }
    
    private func requestRedirectURL(from url: URL, completion: @escaping URLCompletion) {
        if let paymentMethod = self.paymentMethod,
            let plugin = self.pluginManager?.plugin(for: paymentMethod) as? UniversalLinksPlugin,
            plugin.supportsUniversalLinks {
            
            let session = URLSession(configuration: PaymentServer.redirectSessionConfiguration)
            session.dataTask(with: url, completionHandler: { [weak self] data, response, error in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.delegateQueue.async {
                    if let universalLink = response?.url {
                        strongSelf.delegate?.paymentRequest(strongSelf, requiresReturnURLFrom: universalLink, completion: completion)
                    } else {
                        strongSelf.delegate?.paymentRequest(strongSelf, requiresReturnURLFrom: url, completion: completion)
                    }
                }
            }).resume()
        } else {
            delegateQueue.async {
                self.delegate?.paymentRequest(self, requiresReturnURLFrom: url, completion: completion)
            }
        }
    }
    
    private func finish(with result: PaymentRequestResult) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, didFinishWith: result)
        }
    }
}
