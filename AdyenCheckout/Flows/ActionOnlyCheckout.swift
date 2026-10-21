//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Checkout flow for integrations that only need to handle actions.
@MainActor
public final class ActionOnlyCheckout: BaseCheckout {}
