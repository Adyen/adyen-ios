//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCard

internal class CardComponentDelegateMock: CardComponentDelegate {
    
    private let onBINDidChange: (String) -> Void
    private let onCardTypeChange: ([CardType]?) -> Void
    
    internal init(onBINDidChange: @escaping (String) -> Void,
                  onCardTypeChange: @escaping ([CardType]?) -> Void) {
        self.onBINDidChange = onBINDidChange
        self.onCardTypeChange = onCardTypeChange
    }
    
    func didChangeBIN(_ value: String, component: CardComponent) {
        onBINDidChange(value)
    }
    
    func didChangeCardType(_ value: [CardType]?, component: CardComponent) {
        onCardTypeChange(value)
    }
}

internal class BCMCComponentDelegateMock: BCMCComponentDelegate {
    
    private let onBINDidChange: (String) -> Void
    private let onCardTypeChange: (Bool?) -> Void
    
    internal init(onBINDidChange: @escaping (String) -> Void,
                  onCardTypeChange: @escaping (Bool?) -> Void) {
        self.onBINDidChange = onBINDidChange
        self.onCardTypeChange = onCardTypeChange
    }
    
    func didChangeBIN(_ value: String, component: BCMCComponent) {
        onBINDidChange(value)
    }
    
    func didChangeCardType(_ value: Bool?, component: BCMCComponent) {
        onCardTypeChange(value)
    }
}
