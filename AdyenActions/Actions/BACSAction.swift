//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which shoppers can view and
/// download the mandate PDF after paying via BACS direct debit.
public struct BACSAction: Decodable {
    public let downloadUrl: URL
    
    private enum CodingKeys: String, CodingKey {
        case downloadUrl = "url"
    }
}
