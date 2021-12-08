//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form view representing a plain text input.
/// :nodoc:
public final class FormTextInputItemView: FormTextItemView<FormTextInputItem> {

    // MARK: - Initializers

    public required init(item: FormTextInputItem) {
        super.init(item: item)
        bind(item.$isEnabled, to: textField, at: \.isEnabled)
    }
}
