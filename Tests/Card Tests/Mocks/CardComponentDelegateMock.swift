//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import AdyenCard

internal class CardComponentDelegateMock: CardComponentDelegate {
    
    private let onBINDidChange: (String) -> Void
    private let onCardBrandChange: ([CardBrand]?) -> Void
    private let onSubmitLastFour: (String, String) -> Void
    
    internal init(onBINDidChange: @escaping (String) -> Void,
                  onCardBrandChange: @escaping ([CardBrand]?) -> Void,
                  onSubmitLastFour: @escaping ((String, String) -> Void)) {
        self.onBINDidChange = onBINDidChange
        self.onCardBrandChange = onCardBrandChange
        self.onSubmitLastFour = onSubmitLastFour
    }
    
    func didChangeBIN(_ value: String, component: CardComponent) {
        onBINDidChange(value)
    }
    
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        onCardBrandChange(value)
    }

    func didSubmit(lastFour: String, finalBIN: String, component: CardComponent) {
        onSubmitLastFour(lastFour, finalBIN)
    }
}
