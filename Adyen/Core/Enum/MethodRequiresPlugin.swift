//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// List of payment methods that require plugins.
enum MethodRequiresPlugin: String {
    case applepay
    case ideal
    case sepadirectdebit
}
