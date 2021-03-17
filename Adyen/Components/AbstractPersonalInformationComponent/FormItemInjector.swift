//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds a `FormItem` and injects it into a `FormViewController`.
/// :nodoc:
public protocol FormItemInjector {

    /// :nodoc:
    func inject(into formViewController: FormViewController)
}
