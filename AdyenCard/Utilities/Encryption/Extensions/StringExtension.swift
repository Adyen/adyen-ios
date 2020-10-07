//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto

extension String {

    internal func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }

        var keyData = Data()
        keyData.append(contentsOf: digest)
        return keyData.base64EncodedString()
    }

    internal var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        var string = self
        if string.count % 2 == 1 {
            string.insert("0", at: startIndex)
        }

        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else { return nil }
        regex.enumerateMatches(in: string, range: NSRange(startIndex..., in: string)) { match, _, _ in
            let byteString = (string as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }

        guard !data.isEmpty else { return nil }

        return data
    }

}
