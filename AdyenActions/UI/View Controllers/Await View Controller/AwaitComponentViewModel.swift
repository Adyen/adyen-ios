//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Describes the `AwaitViewController` UI elements.
internal struct AwaitComponentViewModel {
    
    /// The await icon name.
    internal let icon: String
    
    /// The await message.
    internal let message: String
    
    /// The spinner title.
    internal let spinnerTitle: String
    
    /// Initializes the `AwaitComponentViewModel`.
    ///
    /// - Parameter icon: The icon name.
    /// - Parameter message: The await message.
    /// - Parameter spinnerTitle: The spinner title.
    internal init(icon: String, message: String, spinnerTitle: String) {
        self.icon = icon
        self.message = message
        self.spinnerTitle = spinnerTitle
    }
    
    /// Initializes the `AwaitComponentViewModel`.
    ///
    /// - Parameter paymentMethodType: The `paymentMethodType` for which the await action is used.
    /// - Parameter localizationParameters: The localization parameters to control some aspects of how strings are localized
    internal static func viewModel(with paymentMethodType: AwaitPaymentMethod,
                                   localizationParameters: LocalizationParameters? = nil) -> AwaitComponentViewModel {
        switch paymentMethodType {
        case .mbway, .blik:
            let localizationKey = LocalizationKey(key: "adyen.\(paymentMethodType.rawValue).confirmPayment")
            return AwaitComponentViewModel(icon: paymentMethodType.rawValue,
                                           message: localizedString(localizationKey, localizationParameters),
                                           spinnerTitle: localizedString(.awaitWaitForConfirmation, localizationParameters))
        }
    }
    
}
