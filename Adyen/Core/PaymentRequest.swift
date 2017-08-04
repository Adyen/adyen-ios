//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let deviceFingerprintVersion = sdkVersion

public typealias DataCompletion = (Data) -> Void
public typealias MethodCompletion = (PaymentMethod) -> Void
public typealias URLCompletion = (URL) -> Void
public typealias CardScanCompletion = ((number: String?, expiryDate: String?, cvc: String?)) -> Void
public typealias PaymentDetailsCompletion = (PaymentDetails) -> Void

/// This class is the starting point for [Custom Integration](https://docs.adyen.com/developers/payments/accepting-payments/in-app-integration).
public final class PaymentRequest {
    
    /// Delegate for controlling the payment flow. See `PaymentRequestDelegate`.
    internal(set) public weak var delegate: PaymentRequestDelegate?
    
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
    
    /**
     Creates a `PaymentRequest` object and initialises it with a provided delegate.
     
     - parameter delegate: An object that implements `PaymentRequestDelegate`.
     
     - returns: An initialised instance of the payment request.
     */
    public init(delegate: PaymentRequestDelegate) {
        self.delegate = delegate
    }
    
    func paymentToken() -> String {
        let fingerprintInfo = [
            "deviceFingerprintVersion": deviceFingerprintVersion,
            "sdkVersion": sdkVersion,
            "deviceIdentifier": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "apiVersion": "3"
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: fingerprintInfo, options: []) else {
            return ""
        }
        
        return data.base64EncodedString()
    }
    
    /// Starts the payment request.
    public func start() {
        let token = paymentToken()
        
        requiresPaymentData(forToken: token) { data in
            guard let paymentSetup = PaymentSetup(data: data) else {
                self.processorFailed(with: .unexpectedData)
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
        guard
            let paymentServer = paymentServer,
            let preferredMethods = preferredMethods, preferredMethods.contains(paymentMethod)
        else {
            completion(false, .unexpectedError)
            
            return
        }
        
        paymentServer.deletePreferredPaymentMethod(paymentMethod) { responseInfo, error in
            completion(false, nil)
            
            guard let responseInfo = responseInfo else {
                completion(false, .unexpectedError)
                return
            }
            
            guard
                let resultCode = responseInfo["resultCode"] as? String,
                resultCode == "Success"
            else {
                completion(false, .unexpectedError)
                return
            }
            
            //  Remove payment method from the list if deletion succeeded.
            if let index = preferredMethods.index(of: paymentMethod) {
                self.preferredMethods?.remove(at: index)
            }
            
            DispatchQueue.main.async {
                completion(true, error)
            }
            
            //  Update list on completion.
            self.requiresPaymentMethod(fromPreferred: self.preferredMethods, available: self.availableMethods ?? [], completion: { method in
                self.continueProcess(with: method)
            })
        }
    }
    
    /// Cancels the payment request.
    public func cancel() {
        didFinish(with: .error(.canceled))
    }
    
    func process(_ paymentSetup: PaymentSetup) {
        self.paymentSetup = paymentSetup
        
        let preferredMethods = paymentSetup.preferredPaymentMethods.filter(isPaymentMethodAvailable(_:))
        self.preferredMethods = preferredMethods
        
        let availableMethods = paymentSetup.availablePaymentMethods.filter(isPaymentMethodAvailable(_:))
        self.availableMethods = availableMethods
        
        //  Suggest payment methods available.
        self.requiresPaymentMethod(fromPreferred: preferredMethods, available: availableMethods) { selectedMethod in
            //  Next Step. Selected payment method.
            //  Continue with Payment Data / Authorize URL.
            self.continueProcess(with: selectedMethod)
            return
        }
    }
    
    func continueProcess(with method: PaymentMethod) {
        paymentMethod = method
        
        if method.requiresPaymentData() {
            continuePaymentFlowRequiresPaymentData()
        } else {
            continueOfferFlow()
        }
    }
    
    func continueOfferFlow() {
        guard
            let paymentServer = paymentServer,
            let paymentMethod = paymentMethod
        else {
            processorFailed(with: .unexpectedError)
            
            return
        }
        
        paymentServer.initiatePayment(for: paymentMethod) { paymentInitiation, error in
            guard
                let paymentInitiation = paymentInitiation,
                error == nil
            else {
                self.processorFailed(with: error)
                
                return
            }
            
            switch paymentInitiation.state {
            case let .redirect(url):
                self.requiresReturnURL(from: url) { url in
                    self.continueRedirectPaymentFlow(with: url)
                }
            case let .completed(status, payload):
                self.completePaymentFlow(using: [
                    "resultCode": status.rawValue,
                    "payload": payload
                ])
            case let .error(error):
                self.processorFailed(with: error)
            }
        }
    }
    
    func continuePaymentFlowRequiresPaymentData() {
        guard
            let paymentMethod = paymentMethod,
            let inputDetails = paymentMethod.inputDetails,
            paymentSetup != nil
        else {
            processorFailed(with: .unexpectedError)
            
            return
        }
        
        let initialDetails = PaymentDetails(details: inputDetails)
        requiresPaymentDetails(initialDetails) { fullfilledDetails in
            paymentMethod.fulfilledPaymentDetails = fullfilledDetails
            
            self.continueProcess(with: paymentMethod)
        }
    }
    
}

internal extension PaymentRequest {
    
    private var finalStatePlugin: PluginRequiresFinalState? {
        guard let paymentMethod = paymentMethod else {
            return nil
        }
        
        return pluginManager?.plugin(for: paymentMethod) as? PluginRequiresFinalState
    }
    
    func processorFailed(with error: Error?) {
        func finish() {
            let finalError = error ?? .unexpectedError
            didFinish(with: .error(finalError))
        }
        
        if let plugin = finalStatePlugin {
            plugin.finish(with: .error, completion: {
                finish()
            })
        } else {
            finish()
        }
    }
    
    func processorFinished(with payment: Payment) {
        func finish() {
            didFinish(with: .payment(payment))
        }
        
        if let plugin = finalStatePlugin {
            plugin.finish(with: payment.status, completion: {
                finish()
            })
        } else {
            finish()
        }
    }
    
}

// MARK: Payment Flow 'Redirect'

internal extension PaymentRequest {
    
    func continueRedirectPaymentFlow(with appUrl: URL) {
        if paymentMethod?.additionalRequiredFields != nil {
            //  Different flow, reinitiate
            reinitiateWithData(from: appUrl)
            return
        }
        
        completeRedirectPaymentFlow(with: appUrl)
    }
    
    func reinitiateWithData(from url: URL) {
        paymentMethod?.providedAdditionalRequiredFields = url.queryParameters()
        
        //call offer flow
        continueOfferFlow()
    }
    
    func completeRedirectPaymentFlow(with appUrl: URL) {
        completePaymentFlow(with: appUrl)
    }
}

// MARK: Payment Flow 'Completion'

internal extension PaymentRequest {
    
    func completePaymentFlow(using info: [String: Any]?) {
        guard
            let resultCode = info?["resultCode"] as? String,
            let status = PaymentStatus(rawValue: resultCode),
            let payload = info?["payload"] as? String,
            let paymentSetup = paymentSetup
        else {
            processorFailed(with: .unexpectedData)
            return
        }
        
        let result = Payment(status: status,
                             method: paymentMethod!,
                             payload: payload,
                             paymentSetup: paymentSetup)
        processorFinished(with: result)
    }
    
    func completePaymentFlow(with appUrl: URL) {
        completePaymentFlow(using: appUrl.queryParameters())
    }
}

// MARK: Delegate Helpers

fileprivate extension PaymentRequest {
    
    private var delegateQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    func requiresPaymentData(forToken token: String, completion: @escaping DataCompletion) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, requiresPaymentDataForToken: token, completion: completion)
        }
    }
    
    func requiresPaymentMethod(fromPreferred preferredMethods: [PaymentMethod]?, available availableMethods: [PaymentMethod], completion: @escaping MethodCompletion) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, requiresPaymentMethodFrom: preferredMethods, available: availableMethods, completion: completion)
        }
    }
    
    func requiresReturnURL(from url: URL, completion: @escaping URLCompletion) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, requiresReturnURLFrom: url, completion: completion)
        }
    }
    
    func requiresPaymentDetails(_ details: PaymentDetails, completion: @escaping PaymentDetailsCompletion) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, requiresPaymentDetails: details, completion: completion)
        }
    }
    
    func didFinish(with result: PaymentRequestResult) {
        delegateQueue.async {
            self.delegate?.paymentRequest(self, didFinishWith: result)
        }
    }
}
