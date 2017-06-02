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
    
    var paymentRequest: InternalPaymentRequest?
    
    var paymentMethodPlugin: BasePlugin!
    
    private let paymentServer = PaymentServer()
    
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
            "deviceIdentifier": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: fingerprintInfo, options: []) else {
            return ""
        }
        
        return data.base64EncodedString()
    }
    
    /// Starts the payment request.
    public func start() {
        let token = paymentToken()
        
        delegate?.paymentRequest(self, requiresPaymentDataForToken: token) { data in
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
    
    /// Cancels the payment request.
    public func cancel() {
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, didFinishWith: .error(.canceled))
        }
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
                self.delegate?.paymentRequest(self, didFinishWith: .error(error))
                return
            }
            
            guard let available = available else {
                self.delegate?.paymentRequest(self, didFinishWith: .error(.unexpectedData))
                return
            }
            
            let availableMethods = available.filter({ (method) -> Bool in
                method.isAvailableOnDevice()
            })
            
            //  Suggest payment methods available.
            self.delegate?.paymentRequest(self, requiresPaymentMethodFrom: preferred, available: availableMethods) { selectedMethod in
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
                    self.delegate?.paymentRequest(self, requiresReturnURLFrom: url) { url in
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
                    error = .message(errorMessage)
                }
                
                self.processorFailed(with: error)
                return
            }
            
            self.processorFailed(with: error)
        }
    }
    
    func continuePaymentFlowRequiresPaymentData() {
        guard paymentRequest != nil, let inputDetails = paymentMethod?.inputDetails else {
            processorFailed(with: nil)
            return
        }
        
        delegate?.paymentRequest(self, requiresPaymentDetails: PaymentDetails(details: inputDetails), completion: { fullfilledDetails in
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
        })
    }
    
    func fetchPaymentMethodsFor(_ payment: InternalPaymentRequest, completion: @escaping PaymentMethodsCompletion) {
        guard
            let json = try? JSONSerialization.jsonObject(with: payment.paymentRequestData, options: []),
            let info = json as? [String: Any],
            let methodsInfo = info["paymentMethods"] as? [[String: Any]]
        else {
            completion(nil, nil, .unexpectedError)
            return
        }
        
        let available = methodsInfo.flatMap({ PaymentMethod(info: $0, logoBaseURL: payment.logoBaseURL) })
        
        //  Group available PM's
        let groupped = available.groupBy { element in
            return element.group?.type ?? UUID().uuidString
        }
        
        let availableGroupped = groupped.flatMap { group -> PaymentMethod? in
            return group.count == 1 ? group[0] : PaymentMethod(group: group)
        }
        
        //  Parse one-click methods
        var preferredMethods = [PaymentMethod]()
        if let recurringDetails = info["recurringDetails"] as? [[String: Any]] {
            preferredMethods = recurringDetails.flatMap({ PaymentMethod(info: $0, logoBaseURL: payment.logoBaseURL, oneClick: true) })
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.delegate?.paymentRequest(self, didFinishWith: .error(finalError))
        }
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
        DispatchQueue.main.async {
            self.delegate?.paymentRequest(self, didFinishWith: .payment(payment))
        }
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
            processorFailed(with: nil)
            return
        }
        
        let result = Payment(payment: paymentRequest, status: status, payload: payload)
        processorFinished(with: result)
    }
    
    func completePaymentFlow(with appUrl: URL) {
        completePaymentFlow(using: appUrl.queryParameters())
    }
}
