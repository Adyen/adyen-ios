//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol GiroPaySearchControllerDelegate: class {
    func didStartNetworkRequest()
    func didFinishNetworkRequest()
    func didFail(with error: Error)
    func didUpdate(with issuers: [GiroPayIssuer])
}

class GiroPaySearchController {
    
    init(delegate: GiroPaySearchControllerDelegate, paymentMethod: PaymentMethod, paymentSession: PaymentSession) {
        self.delegate = delegate
        self.paymentMethod = paymentMethod
        self.paymentSession = paymentSession
    }
    
    // MARK: - Public
    
    var searchString: String = "" {
        didSet {
            didUpdateSearchString()
        }
    }
    
    // MARK: - Private
    
    private let minimumNetworkSearchStringLength = 4
    private let paymentSession: PaymentSession
    private let paymentMethod: PaymentMethod
    
    private var baseString = ""
    private var baseResults = [GiroPayIssuer]()
    private weak var delegate: GiroPaySearchControllerDelegate?
    
    private func didUpdateSearchString() {
        guard searchString.count >= minimumNetworkSearchStringLength else {
            notityEmptySet()
            return
        }
        
        let prefix = String(searchString.prefix(4))
        
        if prefix != baseString {
            baseString = prefix
            fetchIssuersForString()
        } else {
            notityDataChange()
        }
    }
    
    private func fetchIssuersForString() {
        let request = GiroPayIssuersRequest(searchString: baseString, paymentSession: paymentSession, paymentMethod: paymentMethod)
        
        delegate?.didStartNetworkRequest()
        
        APIClient().perform(request) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    self?.delegate?.didFail(with: error)
                case let .success(response):
                    self?.baseResults = response.issuers ?? []
                    self?.notityDataChange()
                }
                
                self?.delegate?.didFinishNetworkRequest()
            }
        }
    }
    
    private func notityEmptySet() {
        self.delegate?.didUpdate(with: [])
    }
    
    private func notityDataChange() {
        self.delegate?.didUpdate(with: filteredResults())
    }
    
    private func filteredResults() -> [GiroPayIssuer] {
        let searchSubstrings = searchString.split(separator: " ")
        
        return baseResults.filter({
            $0.bankName.containsIgnoringCase(subStrings: searchSubstrings) ||
                $0.bic.containsIgnoringCase(string: searchString) ||
                $0.blz.containsIgnoringCase(string: searchString)
        })
    }
    
}

private extension String {
    func containsIgnoringCase(string: String) -> Bool {
        return self.range(of: string, options: .caseInsensitive) != nil
    }
    
    func containsIgnoringCase(subStrings: [Substring]) -> Bool {
        return subStrings.map({
            self.containsIgnoringCase(string: String($0))
        }).reduce(true) { $0 && $1 }
    }
}
