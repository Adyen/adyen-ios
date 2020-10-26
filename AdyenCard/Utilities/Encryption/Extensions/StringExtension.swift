//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

extension String {

    internal var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        var string = self
        if string.count % 2 == 1 {
            string.insert("0", at: startIndex)
        }

        guard let regex = try? NSRegularExpression(pattern: "[0-9a-fA-F]{1,2}", options: .caseInsensitive) else { return nil }
        regex.enumerateMatches(in: string, range: NSRange(startIndex..., in: string)) { match, _, _ in
            let byteString = (string as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }

        guard !data.isEmpty else { return nil }

        return data
    }

}
