//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

extension Cryptor {

    // swiftlint:disable identifier_name

    /// Set of helpers for RSA encryption.
    internal enum AES {

        public enum Error: Swift.Error {
            case cryptoError(CCCryptorStatus)
        }

        private static let CCM_BLOCKSIZE = kCCBlockSizeAES128

        internal func dh(d: UnsafeRawPointer) -> NSData {
            return NSData(bytes: d, length: kCCBlockSizeAES128)
        }

        internal static func encrypt(data: Data, withKey key: Data, iv: Data) -> Data {
            return self.encrypt(data: data, withKey: key, iv: iv, tagLength: 8)
        }

        internal static func encrypt(data: Data, withKey key: Data, iv: Data, tagLength: Int) -> Data {
            return self.encrypt(data: data as NSData,
                                withKey: key as NSData,
                                iv: iv as NSData,
                                tagLength: tagLength)
        }

        private static func encrypt(data: NSData,
                                    withKey key: NSData,
                                    iv: NSData,
                                    tagLength: Int) -> Data {

            let cipher = NSMutableData(bytes: (data as NSData).bytes, length: data.count + tagLength)

            let LSize = 15 - iv.count
            let mutableIv = NSMutableData(bytes: iv.bytes, length: iv.count)
            ccm_encrypt_message(key.bytes, key.length,
                                tagLength, LSize, mutableIv.mutableBytes,
                                cipher.mutableBytes, data.length)

            return cipher as Data
        }

        @discardableResult
        private static func aes_encrypt(_ key: UnsafeRawPointer,
                                        _ keyLength: Int,
                                        _ bytes: UnsafeRawPointer,
                                        _ cipher: UnsafeMutableRawPointer) -> CCCryptorStatus {

            var numBytesEncrypted = 0
            let cryptStatus = CCCrypt(CCOperation(kCCEncrypt),
                                      CCAlgorithm(kCCAlgorithmAES),
                                      CCOptions(kCCOptionECBMode),
                                      key, keyLength,
                                      nil,
                                      bytes, kCCBlockSizeAES128,
                                      cipher, kCCBlockSizeAES128,
                                      &numBytesEncrypted)

            guard cryptStatus == kCCSuccess else {
                return CCCryptorStatus(kCCInvalidKey)
            }

            return cryptStatus
        }

        private static func CCM_FLAGS(_ A: Int, _ M: Int, _ L: Int) -> Int {
            (((A > 0 ? 1 : 0) << 6) | (((M - 2) / 2) << 3) | (L - 1))
        }

        private static func CCM_MASK_L(_ L: Int) -> Int {
            ((1 << 8 * L) - 1)
        }

        private static func CCM_SET_COUNTER(_ A: NSMutableData, _ L: Int, _ cnt: UInt) {
            var index = CCM_BLOCKSIZE - 1
            memset(A.mutableBytes.advanced(by: CCM_BLOCKSIZE - L), 0, L)
            var C = cnt & UInt(CCM_MASK_L(L))
            while C > 0, index > L {
                let value = A.mutableBytes.load(fromByteOffset: index, as: UInt.self) | (C & 0xFF)
                A.mutableBytes.storeBytes(of: value, toByteOffset: index, as: UInt.self)
                index += -1
                C = C >> 8
            }
        }

        // XORs `n` bytes byte-by-byte starting at `y` to the memory area starting at `x`.
        private static func ccm_memxor(_ x: UnsafeMutableRawPointer, _ y: UnsafeMutableRawPointer, _ n: Int) {
            for index in 0...n {
                let valueX = x.load(fromByteOffset: index, as: UniChar.self)
                let valueY = y.load(fromByteOffset: index, as: UniChar.self)
                x.storeBytes(of: valueX ^ valueY, toByteOffset: index, as: UniChar.self)
            }
        }

        private static func ccm_block0(m: Int, /* number of auth bytes */
                                       l: Int, /* number of bytes to encode message length */
                                       la: Int, /* l(a) octets additional authenticated data */
                                       lm: Int, /* l(m) message length */
                                       nonce: UnsafeRawPointer) -> NSMutableData {
            let result = NSMutableData()
            result.mutableBytes.storeBytes(of: CCM_FLAGS(la, m, l), as: Int.self)

            /* copy the nonce */
            memcpy(result.mutableBytes.advanced(by: 1), nonce, CCM_BLOCKSIZE - l)
            var lm = lm
            for index in 0...l { // (int index=0; index < L; index++) {
                result.mutableBytes.storeBytes(of: UniChar(lm & 0xFF), toByteOffset: 15 - index, as: UniChar.self)
                lm = lm >> 8
            }

            return result
        }

        private static func ccm_encrypt_xor(_ key: UnsafeRawPointer,
                                            _ keyLength: Int,
                                            _ L: Int,
                                            _ counter: UInt,
                                            _ msg: UnsafeMutableRawPointer,
                                            _ ln: Int,
                                            _ A: NSMutableData,
                                            _ S: NSMutableData) {
            CCM_SET_COUNTER(A, L, counter)
            aes_encrypt(key, keyLength, A.mutableBytes, S.mutableBytes)
            ccm_memxor(msg, S.mutableBytes, ln)
        }

        private static func ccm_mac(_ key: UnsafeRawPointer,
                                    _ keyLength: Int,
                                    _ msg: UnsafeRawPointer,
                                    _ len: Int,
                                    _ B: NSMutableData,
                                    _ X: NSMutableData) {
            for index in 0...len {
                let value = X.mutableBytes.advanced(by: index).load(as: UniChar.self) ^ msg.advanced(by: index).load(as: UniChar.self)
                B.mutableBytes.storeBytes(of: value, toByteOffset: index, as: UniChar.self)
            }

//            #if ADYC_AESCCM_TraceLog
//            NSLog(@"ccm_mac: %@", dh(B));
//            #endif

            aes_encrypt(key, keyLength, B.mutableBytes, X.mutableBytes)

//            #if ADYC_AESCCM_TraceLog
//            NSLog(@"ccm_mac e: %@", dh(X));
//            #endif
        }

        private static func dtls_int_to_uint16(_ field: UnsafeMutableRawPointer, _ value: Int) {
            field.storeBytes(of: UniChar((value >> 8) & 0xFF), as: UniChar.self)
            field.storeBytes(of: UniChar(value & 0xFF), toByteOffset: 1, as: UniChar.self)
        }

        /**
         * Creates the CBC-MAC for the additional authentication data that
         * is sent in cleartext. The result is written to `X`.
         *
         * @param key The AES key
         * @param kL  The AES key length
         * @param msg  The message starting with the additional authentication data.
         * @param la   The number of additional authentication bytes in msg.
         * @param B    The input buffer for crypto operations. When this function
         *             is called, B must be initialized with B0 (the first
         *             authentication block.
         * @param X    The output buffer where the result of the CBC calculation
         *             is placed.
         */
        private static func ccm_add_auth_data(_ key: UnsafeRawPointer,
                                              _ keyLength: Int,
                                              _ msg: NSData,
                                              _ la: Int,
                                              _ B: NSMutableData,
                                              _ X: NSMutableData) {
            aes_encrypt(key, keyLength, B.mutableBytes, X.mutableBytes)
            memset(B.mutableBytes, 0, CCM_BLOCKSIZE)

            guard la > 0, la < 0xFF00 else { return }

            /* Here we are building for small devices and thus
             * anticipate that the number of additional authentication bytes
             * will not exceed 65280 bytes (0xFF00) and we can skip the
             * workarounds required for j=6 and j=10 on devices with a word size
             * of 32 bits or 64 bits, respectively.
             */

            var la = la
            dtls_int_to_uint16(B.mutableBytes, la)

            memcpy(B.mutableBytes.advanced(by: 2), msg.bytes, min(CCM_BLOCKSIZE - 2, la))
            la += -min(CCM_BLOCKSIZE - 2, la)
            var msg = msg.bytes.advanced(by: min(CCM_BLOCKSIZE - 2, la))

            ccm_memxor(B.mutableBytes, X.mutableBytes, CCM_BLOCKSIZE)

            aes_encrypt(key, keyLength, B.mutableBytes, X.mutableBytes)

            while la > CCM_BLOCKSIZE {
                for i in 0...CCM_BLOCKSIZE {
                    let value = X.bytes.load(fromByteOffset: i, as: UniChar.self) ^ msg.load(as: UniChar.self)
                    B.mutableBytes.storeBytes(of: value, toByteOffset: i, as: UniChar.self)
                    msg = msg.advanced(by: 1)
                }
                la -= CCM_BLOCKSIZE

                aes_encrypt(key, keyLength, B.mutableBytes, X.mutableBytes)
            }

            if la > 0 {
                memset(B.mutableBytes, 0, CCM_BLOCKSIZE)
                memcpy(B.mutableBytes, msg, la)
                ccm_memxor(B.mutableBytes, X.mutableBytes, CCM_BLOCKSIZE)

                aes_encrypt(key, keyLength, B.mutableBytes, X.mutableBytes)
            }
        }

        /**
         * Authenticates and encrypts a message using AES in CCM mode. Please
         * see also RFC 3610 for the meaning of  M,  L,  lm and  la.
         *
         * @param key   The AES key
         * @param kL    The AES key length
         * @param M     The number of authentication octets.
         * @param L     The number of bytes used to encode the message length.
         * @param nonce The nonce value to use. You must provide  CCM_BLOCKSIZE
         *              nonce octets, although only the first  16 -  L are used.
         * @param msg   The message to encrypt. The first  la octets are additional
         *              authentication data that will be cleartext. Note that the
         *              encryption operation modifies the contents of  msg and adds
         *              M bytes MAC. Therefore, the buffer must be at least
         *              lm +  M bytes large.
         * @param lm    The actual length of  msg.
         * @param aad   A pointer to the additional authentication data (can be  NULL if
         *              la is zero).
         * @param la    The number of additional authentication octets (may be zero).
         * @return length
         */
        private static func
            ccm_encrypt_message(_ key: UnsafeRawPointer,
                                _ kL: Int,
                                _ M: Int,
                                _ L: Int,
                                _ nonce: UnsafeRawPointer,
                                _ msg: UnsafeMutableRawPointer,
                                _ lm: Int) -> Int
        {
            let len = lm /* save original length */
            var counter: UInt = 1 /// @bug does not work correctly on ia32 when lm >= 2^16
            let A = NSMutableData() /* A_i blocks for encryption input */
            let B = ccm_block0(m: M, l: L, la: 0, lm: lm, nonce: nonce) /* B_i blocks for CBC-MAC input */
            let S = NSMutableData() /* S_i = encrypted A_i blocks */
            let X = NSMutableData() /* X_i = encrypted B_i blocks */

            /* create the initial authentication block B0 */

//            #if ADYC_AESCCM_TraceLog
//            NSLog(@"ccm_block0: %@", dh(B));
//            #endif

            aes_encrypt(key, kL, B.mutableBytes, X.mutableBytes)
            memset(B.mutableBytes, 0, CCM_BLOCKSIZE)

//            #if ADYC_AESCCM_TraceLog
//            NSLog(@"ccm_add_auth_data: B: %@ X: %@", dh(B), dh(X));
//            #endif

            /* initialize block template */
            A.mutableBytes.storeBytes(of: L - 1, as: Int.self)

            // copy the nonce
            memcpy(A.mutableBytes.advanced(by: 1), nonce, CCM_BLOCKSIZE - L)

            var lm = lm
            var msg = msg
            while lm >= CCM_BLOCKSIZE {
                // calculate MAC
                ccm_mac(key, kL, msg, CCM_BLOCKSIZE, B, X)

                // encrypt
                ccm_encrypt_xor(key, kL, L, counter, msg, CCM_BLOCKSIZE, A, S)

                // update local pointers
                lm -= CCM_BLOCKSIZE
                msg = msg.advanced(by: CCM_BLOCKSIZE)
                counter += 1
            }

            if lm > 0 {
                /* Calculate MAC. The remainder of B must be padded with zeroes, so
                 * B is constructed to contain X ^ msg for the first lm bytes (done in
                 * mac() and X ^ 0 for the remaining CCM_BLOCKSIZE - lm bytes
                 * (i.e., we can use memcpy() here).
                 */
                memcpy(B.mutableBytes.advanced(by: lm), X.bytes.advanced(by: lm), CCM_BLOCKSIZE - lm)
                ccm_mac(key, kL, msg, lm, B, X)

                // encrypt
                ccm_encrypt_xor(key, kL, L, counter, msg, lm, A, S)

                // update local pointers
                msg += lm
            }

            // calculate S_0
            CCM_SET_COUNTER(A, L, 0)

            aes_encrypt(key, kL, A.mutableBytes, S.mutableBytes)

            for i in 0...M {
                let value = X.bytes.load(fromByteOffset: i, as: UniChar.self) ^ S.bytes.load(fromByteOffset: i, as: UniChar.self)
                msg.storeBytes(of: value, toByteOffset: i, as: UniChar.self)
            }

            return len + M
        }

    }

}
