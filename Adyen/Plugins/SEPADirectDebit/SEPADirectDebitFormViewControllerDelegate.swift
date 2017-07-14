//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol SEPADirectDebitFormViewControllerDelegate: class {
    
    /// Invoked when the form is submitted.
    ///
    /// - Parameters:
    ///   - formViewController: The form view controller which has been submitted.
    ///   - iban: A validated IBAN that has been filled in.
    ///   - name: A validated name that has been filled in.
    func formViewController(_ formViewController: SEPADirectDebitFormViewController, didSubmitWithIBAN iban: String, name: String)
    
}
