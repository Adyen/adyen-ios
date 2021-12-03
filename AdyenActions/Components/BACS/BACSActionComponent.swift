//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

/// A component that handles actions after paying with BACS direct debit.
public final class BACSActionComponent: ActionComponent {
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    public init(apiContext: APIContext) {
        self.apiContext = apiContext
    }
    
    public func handle(_ action: BACSAction) {}
}
