//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

extension Cryptor {

    internal typealias EncryptionResult = (cipher: Data?, atag: Data?)

    /// Set of supported AES alghoritms.
    /// :nodoc:
    internal enum AES: Int {

        case CCM = 1

        @available(iOS 13.0, *)
        case GCM = 2

        /// Encrypt data using a key and IV.
        /// - Parameters:
        ///   - data: Set of bytes represents secret message.
        ///   - key: Random or pseudorandom bytes. The length should be 128 bits.
        ///   - initVector: Random or pseudorandom bytes. The length depends on selected alghoritm. See `ivLength`.
        /// - Returns: Encrypted data or nil.
        /// :nodoc:
        internal func encrypt(data: NSData, withKey key: NSData, initVector: NSData) -> EncryptionResult {
            let cipher = encryptor.init(data: data, key: key, initVector: initVector)
            return (cipher?.cipherData, cipher?.tag)
        }

        /// Length of the initial vector (nonce).
        /// :nodoc:
        internal var ivLength: Int {
            12
        }

        private var encryptor: AESEncryptor.Type {
            if #available(iOS 13.0, *) {
                if self == .GCM {
                    return GCMEncryptor.self
                }
            }

            return CCMEncryptor.self
        }
    }
}

internal protocol AESEncryptor {
    var cipherData: Data { get }
    var tag: Data? { get }
    init?(data: NSData, key: NSData, initVector: NSData)
}

extension AESEncryptor {
    internal var tag: Data? { nil }
}

extension Cryptor.AES {

    internal typealias Bytes = UnsafeBufferPointer<UInt8>
    internal typealias MutableBytes = UnsafeMutableBufferPointer<UInt8>
    internal typealias Pointer = UnsafeMutablePointer<UInt8>

}

extension UnsafeMutableBufferPointer {

    internal func memecpy(from source: UnsafePointer<Element>, offset: Int, count: Int) {
        for index in offset..<(offset + count) {
            self[index] = source.advanced(by: index - offset).pointee
        }
    }

    internal func memecpy<T: RandomAccessCollection>(from source: T, offset: Int, count: Int) where T.Element == Element, T.Index == Int {
        for index in offset..<(offset + count) {
            self[index] = source[index - offset]
        }
    }

    internal func memset(value: Element, offset: Int, count: Int) {
        for index in offset..<offset + count {
            self[index] = value
        }
    }

}
