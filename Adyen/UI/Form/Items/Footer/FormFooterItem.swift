//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a footer, including a submit button.
/// :nodoc:
public final class FormFooterItem: FormItem {
    
    /// The title of the footer.
    public var title: String?
    
    /// The title of the submit button.
    public var submitButtonTitle: String?
    
    /// The title of the submit button.
    public var showsActivityIndicator = Observable(false)
    
    /// A closure that will be invoked when the submit button is selected.
    public var submitButtonSelectionHandler: (() -> Void)?
    
    /// Initializes the footer item.
    public init() {}
    
}
