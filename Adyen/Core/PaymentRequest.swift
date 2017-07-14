//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

let deviceFingerprintVersion = sdkVersion

public typealias PaymentMethodsCompletion = (_ preferredMethods: [PaymentMethod]?, _ availableMethods: [PaymentMethod]?, _ error: Error?) -> Void
public typealias DataCompletion = (Data) -> Void
public typealias MethodCompletion = (PaymentMethod) -> Void
public typealias URLCompletion = (URL) -> Void
public typealias PaymentDetailsCompletion = (PaymentDetails) -> Void

/// This class is the starting point for [Custom Integration](https://docs.adyen.com/developers/payments/accepting-payments/in-app-integration).
public final class PaymentRequest {
    
    /// Delegate for controlling the payment flow. See `PaymentRequestDelegate`.
    public internal(set) weak var delegate: PaymentRequestDelegate?
    
    /// The selected payment method.
    public private(set) var paymentMethod: PaymentMethod?
    
    /// Amount to be charged.
    public private(set) var amount: Int?
    
    /// Payment currency.
    public private(set) var currency: String?
    
    /// Payment reference.
    public private(set) var reference: String?
    
    /// Payment country code.
    public private(set) var countryCode: String?
    
    /// Shopper locale.
    public private(set) var shopperLocale: String?
    
    /// Shopper reference.
    public private(set) var shopperReference: String?
    
    /// Generation time. Used for generating a token for card payments.
    public private(set) var generationTime: String?
    
    /// Public key. Used for generating a token for card payments.
    public private(set) var publicKey: String?
    
    var paymentRequest: InternalPaymentRequest?
    
    var paymentMethodPlugin: BasePlugin!
    
    private let paymentServer = PaymentServer()
    
    private var preferredMethods: [PaymentMethod]?
    
    private var availableMethods: [PaymentMethod]?
    
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
            "apiVersion": "2"
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
            guard let internalRequest = InternalPaymentRequest(data: data) else {
                self.processorFailed(with: .unexpectedData)
                return
            }
            
            //  Public properties
            self.amount = internalRequest.amount
            self.currency = internalRequest.currency
            self.reference = internalRequest.merchantReference
            self.countryCode = internalRequest.country
            self.shopperLocale = internalRequest.shopperLocale
            self.shopperReference = internalRequest.shopperReference
            self.publicKey = internalRequest.publicKey
            self.generationTime = internalRequest.generationTime
            
            self.process(internalRequest)
        }
    }
    
    /// Permanently deletes payment method from shopper's preferred payment options.
    public func deletePreferred(paymentMethod: PaymentMethod, completion: @escaping (Bool, Error?) -> Void) {
        paymentMethod.plugin?.paymentRequest = paymentRequest
        
        guard
            let preferredMethods = preferredMethods,
            let paymentRequest = paymentRequest,
            let url = paymentRequest.deletePreferredURL,
            let requestInfo = paymentMethod.plugin?.deleteRequestInfo()
        else {
            // Call completion with error.
            completion(false, .unexpectedError)
            return
        }
        
        if preferredMethods.contains(paymentMethod) == false {
            completion(false, .unexpectedError)
            return
        }
        
        paymentServer.post(url: url, info: requestInfo) { responseInfo, error in
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
    
    func process(_ paymentRequest: InternalPaymentRequest) {
        self.paymentRequest = paymentRequest
        
        if let method = paymentRequest.paymentMethod {
            continueProcess(with: method)
            return
        }
        
        //  No payment method set. Fetch payment methods.
        fetchPaymentMethodsFor(paymentRequest) { preferred, available, error in
            
            if let error = error {
                self.didFinish(with: .error(error))
                return
            }
            
            guard let available = available else {
                self.didFinish(with: .error(.unexpectedData))
                return
            }
            
            let availableMethods = available.filter({ (method) -> Bool in
                method.isAvailableOnDevice()
            })
            
            self.preferredMethods = preferred
            self.availableMethods = availableMethods
            
            //  Suggest payment methods available.
            self.requiresPaymentMethod(fromPreferred: preferred, available: availableMethods) { selectedMethod in
                //  Next Step. Selected payment method.
                //  Continue with Payment Data / Authorize URL.
                self.continueProcess(with: selectedMethod)
                return
            }
        }
    }
    
    func continueProcess(with method: PaymentMethod) {
        paymentMethod = method
        paymentRequest?.paymentMethod = method
        
        if let plugin = paymentRequest?.paymentMethod?.plugin {
            plugin.paymentRequest = paymentRequest
        }
        
        if method.requiresPaymentData() {
            continuePaymentFlowRequiresPaymentData()
        } else {
            continueOfferFlow()
        }
    }
    
    func continueOfferFlow() {
        //  Make offer request
        guard
            let offerUrl = paymentRequest?.initiationURL,
            let offerInfo = paymentRequest?.paymentMethod?.plugin?.offerRequestInfo()
        else {
            processorFailed(with: .unexpectedError)
            return
        }
        
        paymentServer.post(url: offerUrl, info: offerInfo) { responseInfo, error in
            guard
                let responseInfo = responseInfo,
                let flowType = responseInfo["type"] as? String,
                error == nil
            else {
                self.processorFailed(with: error)
                return
            }
            
            self.paymentRequest?.paymentMethod?.additionalRequiredFields = responseInfo["requiredFields"] as? [String: Any]
            
            if flowType == "redirect" {
                if let redirectUrl = responseInfo["url"] as? String {
                    let url = URL(string: redirectUrl)!
                    self.requiresReturnURL(from: url) { url in
                        self.continueRedirectPaymentFlow(with: url)
                    }
                    return
                }
            } else if flowType == "complete" {
                if (responseInfo["payload"] as? String) != nil {
                    self.completePaymentFlow(using: responseInfo)
                    return
                }
            } else if flowType == "error" {
                var error: Error = .unexpectedError
                if let errorMessage = responseInfo["errorMessage"] as? String {
                    error = .serverError(errorMessage)
                }
                
                self.processorFailed(with: error)
                return
            }
            
            self.processorFailed(with: error)
        }
    }
    
    func continuePaymentFlowRequiresPaymentData() {
        guard paymentRequest != nil, let inputDetails = paymentMethod?.inputDetails else {
            processorFailed(with: .unexpectedError)
            return
        }
        
        let initialDetails = PaymentDetails(details: inputDetails)
        requiresPaymentDetails(initialDetails) { fullfilledDetails in
            //  Convert `details` to providedPaymentData
            var pairs = [String: Any]()
            for detail in fullfilledDetails.list {
                if let value = detail.value {
                    pairs[detail.key] = value
                }
            }
            
            self.paymentRequest?.paymentMethod?.plugin?.providedPaymentData = pairs
            
            if let method = self.paymentRequest?.paymentMethod {
                self.continueProcess(with: method)
            }
        }
    }
    
    func fetchPaymentMethodsFor(_ payment: InternalPaymentRequest, completion: @escaping PaymentMethodsCompletion) {
        guard
            let json = try? JSONSerialization.jsonObject(with: payment.paymentRequestData, options: []),
            let info = json as? [String: Any],
            let methodsInfo = info["paymentMethods"] as? [[String: Any]]
        else {
            completion(nil, nil, .unexpectedData)
            return
        }
        
        let available = methodsInfo.flatMap { PaymentMethod(info: $0, logoBaseURL: payment.logoBaseURL, isOneClick: false) }
        
        //  Group available PM's
        let groupped = available.groupBy { element in
            return element.group?.type ?? UUID().uuidString
        }
        
        let availableGroupped = groupped.flatMap { members -> PaymentMethod? in
            return members.count == 1 ? members[0] : PaymentMethod(members: members)
        }
        
        //  Parse one-click methods
        var preferredMethods = [PaymentMethod]()
        if let recurringDetails = info["recurringDetails"] as? [[String: Any]] {
            preferredMethods = recurringDetails.flatMap({ PaymentMethod(info: $0, logoBaseURL: payment.logoBaseURL, isOneClick: true) })
        }
        
        completion(preferredMethods, availableGroupped, nil)
    }
}

internal extension PaymentRequest {
    
    func processorFailed(with error: Error?) {
        //  Update Payment Method plugin if required
        if let plugin = paymentRequest?.paymentMethod?.plugin as? RequiresFinalState {
            plugin.finishWith(state: .error) {
                self.processorFailedStep2(with: error)
            }
            return
        }
        
        processorFailedStep2(with: error)
    }
    
    func processorFailedStep2(with error: Error?) {
        //  Report to delegate
        let finalError = error ?? .unexpectedError
        didFinish(with: .error(finalError))
    }
    
    func processorFinished(with result: Payment) {
        if let plugin = paymentRequest?.paymentMethod?.plugin as? RequiresFinalState {
            plugin.finishWith(state: result.status) {
                self.finishRequest(with: result)
            }
            return
        }
        
        finishRequest(with: result)
    }
    
    func finishRequest(with payment: Payment) {
        didFinish(with: .payment(payment))
    }
}

// MARK: Payment Flow 'Redirect'

internal extension PaymentRequest {
    
    func continueRedirectPaymentFlow(with appUrl: URL) {
        if paymentRequest?.paymentMethod?.additionalRequiredFields != nil {
            //  Different flow, reinitiate
            reinitiateWithData(from: appUrl)
            return
        }
        
        completeRedirectPaymentFlow(with: appUrl)
    }
    
    func reinitiateWithData(from url: URL) {
        paymentRequest?.paymentMethod?.providedAdditionalRequiredFields = url.queryParameters()
        
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
            let paymentRequest = paymentRequest
        else {
            processorFailed(with: .unexpectedData)
            return
        }
        
        let result = Payment(status: status,
                             method: paymentMethod!,
                             payload: payload,
                             internalRequest: paymentRequest)
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
