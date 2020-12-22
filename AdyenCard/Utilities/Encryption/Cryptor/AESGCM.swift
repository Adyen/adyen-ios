//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import CryptoKit
import Foundation

extension Cryptor.AES {

    @available(iOS 13.0, *)
    internal struct AESGCMEncryptor: AESEncryptor {

        private let box: AES.GCM.SealedBox

        public var cipherData: Data {
            box.ciphertext
        }

        public var tag: Data? {
            box.tag
        }

        init?(data: NSData, key: NSData, initVector: NSData) {
            let symmetricKey = SymmetricKey(data: key as Data)

            guard
                let nonce = try? AES.GCM.Nonce(data: initVector),
                let box = try? AES.GCM.seal(data, using: symmetricKey, nonce: nonce) else {
                return nil
            }

            self.box = box
        }
    }
}
