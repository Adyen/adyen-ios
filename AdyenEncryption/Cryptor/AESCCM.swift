//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import CommonCrypto
import Foundation

extension Cryptor.AES {

    /**
      Authenticates and encrypts a message using AES in CCM mode.
      Please see also RFC 3610 for the meaning of  M,  L,  lm and  la.

     By default the number of additional authentication octets is zero.
     */
    internal struct CCMEncryptor: AESEncryptor {

        /// The number of authentication octets.
        private let authOctets = 8 // M

        /// The number of bytes used to encode the message length.
        private let encodeBytesLength: Int // L

        /// The AES key
        private let key: Bytes

        /// The nonce value to use. You must provide `AESCCM.blockSize`
        /// octets, although only the first  16 - L are used.
        private let nonce: Bytes

        /// The actual length of  msg.
        private let messageLength: Int // lm

        /// A_i blocks for encryption input
        private let blockA: MutableBytes

        /// B_i blocks for CBC-MAC input
        private let blockB: MutableBytes

        /// S_i = encrypted A_i blocks
        private let blockS: MutableBytes

        /// X_i = encrypted B_i blocks
        private let blockX: MutableBytes

        /**  The encrypted message.
         *   Note that the encryption operation modifies the contents of  msg and adds
         *   M bytes MAC. Therefore, the buffer must be at least lm +  M bytes large.
         */
        private let cipher: MutableBytes

        internal var cipherData: Data { Data(bytes: cipher.baseAddress!, count: cipher.count) }

        internal init?(data: NSData, key: NSData, initVector: NSData) {

            encodeBytesLength = 15 - initVector.count
            messageLength = data.count
            nonce = Bytes(start: initVector.bytes.assumingMemoryBound(to: UInt8.self), count: 16)
            self.key = Bytes(start: key.bytes.assumingMemoryBound(to: UInt8.self), count: key.count)

            let dataPointer = data.bytes.assumingMemoryBound(to: UInt8.self)
            cipher = MutableBytes.allocate(capacity: data.count + authOctets)
            cipher.memecpy(from: dataPointer, offset: 0, count: data.count)

            blockS = MutableBytes.allocate(capacity: AESCCM.blockSize)
            blockX = MutableBytes.allocate(capacity: AESCCM.blockSize)
            blockA = AESCCM.blockA(encodeBytes: encodeBytesLength, nonce: nonce)
            blockB = AESCCM.blockB(authOctets: authOctets,
                                   messageLength: messageLength,
                                   encodeBytes: encodeBytesLength,
                                   nonce: nonce)
            encryptMessage()
        }

        internal func encryptMessage() {

            AESCCM.aesEncrypt(block: blockB, with: key, saveTo: blockX)
            blockB.initialize(repeating: 0)

            var unencryptedMessageLength = messageLength
            var cipherPointer = cipher.baseAddress!
            var counter: UInt = 1 /// @bug does not work correctly on ia32 when lm >= 2^16
            while unencryptedMessageLength >= AESCCM.blockSize {

                encryptMAC(from: cipherPointer,
                           count: AESCCM.blockSize,
                           counter: counter)

                // update local pointers
                unencryptedMessageLength -= AESCCM.blockSize
                cipherPointer = cipherPointer.advanced(by: AESCCM.blockSize)
                counter += 1
            }

            if unencryptedMessageLength > 0 {
                /* Calculate MAC. The remainder of B must be padded with zeroes, so
                 * B is constructed to contain X ^ msg for the first lm bytes (done in
                 * mac() and X ^ 0 for the remaining CCM_BLOCKSIZE - lm bytes
                 * (i.e., we can use memcpy() here).
                 */
                blockB.memecpy(from: blockX.baseAddress!.advanced(by: unencryptedMessageLength),
                               offset: unencryptedMessageLength,
                               count: AESCCM.blockSize - unencryptedMessageLength)

                encryptMAC(from: cipherPointer,
                           count: unencryptedMessageLength,
                           counter: counter)

                // update local pointers
                cipherPointer = cipherPointer.advanced(by: unencryptedMessageLength)
            }

            // calculate S_0
            AESCCM.setCounter(blockA, encodeBytesLength, 0)
            AESCCM.aesEncrypt(block: blockA, with: key, saveTo: blockS)

            for index in 0..<authOctets {
                cipherPointer.initialize(to: UInt8(blockX[index] ^ blockS[index]))
                cipherPointer = cipherPointer.successor()
            }
        }

        private func encryptMAC(from pointer: Pointer,
                                count: Int,
                                counter: UInt) {
            // calculate MAC
            AESCCM.mac(key: key,
                       pointer: pointer,
                       length: count,
                       blockB: blockB,
                       blockX: blockX)

            // encrypt
            let context = AESCCM.EncryptXorContext(key: key,
                                                   encodeBytes: encodeBytesLength,
                                                   counter: counter,
                                                   pointer: pointer,
                                                   length: count,
                                                   blockA: blockA,
                                                   blockS: blockS)
            AESCCM.encryptXor(context: context)
        }

        private enum AESCCM {

            // Block size.
            internal static let blockSize = kCCBlockSizeAES128

            internal static func aesEncrypt(block: MutableBytes,
                                            with key: Bytes,
                                            saveTo cipher: MutableBytes) {
                var numBytesEncrypted = 0
                CCCrypt(CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(kCCOptionECBMode),
                        key.baseAddress, key.count,
                        nil,
                        block.baseAddress, blockSize,
                        cipher.baseAddress, blockSize,
                        &numBytesEncrypted)
            }

            internal static func setCounter(_ block: MutableBytes, _ encodeBytesLength: Int, _ counter: UInt) {
                block.memset(value: 0, offset: blockSize - encodeBytesLength, count: encodeBytesLength)

                var shift = counter & UInt(encodingMask(encodeBytesLength))
                var index = blockSize - 1
                while shift > 0, index > encodeBytesLength {
                    block[index] |= UInt8(shift & 0xFF)
                    index -= 1
                    shift >>= 8
                }
            }

            // XORs `n` bytes byte-by-byte starting at `y` to the memory area starting at `x`.
            internal static func memxor(_ pointer: Pointer, _ bytes: MutableBytes, _ count: Int) {
                var pointer = pointer
                for index in 0..<count {
                    pointer.initialize(to: pointer.pointee ^ UInt8(bytes[index]))
                    pointer = pointer.successor()
                }
            }

            /// Blocks for CBC-MAC input
            internal static func blockB(authOctets: Int, messageLength: Int, encodeBytes: Int, nonce: Bytes) -> MutableBytes {
                let blockB = MutableBytes.allocate(capacity: AESCCM.blockSize)
                blockB[0] = AESCCM.ccmFlags(authOctets, encodeBytes)

                /* copy the nonce */
                blockB.memecpy(from: nonce, offset: 1, count: AESCCM.blockSize - encodeBytes)

                var shift = messageLength
                for index in 0..<encodeBytes {
                    blockB[15 - index] = UInt8(shift & 0xFF)
                    shift >>= 8
                }

                return blockB
            }

            /// Blocks for encryption input.
            internal static func blockA(encodeBytes: Int, nonce: Bytes) -> MutableBytes {
                let blockA = MutableBytes.allocate(capacity: AESCCM.blockSize)
                blockA[0] = UInt8(encodeBytes - 1)

                // copy the nonce
                blockA.memecpy(from: nonce, offset: 1, count: AESCCM.blockSize - encodeBytes)

                return blockA
            }

            internal struct EncryptXorContext {
                var key: Bytes
                var encodeBytes: Int
                var counter: UInt
                var pointer: Pointer
                var length: Int
                var blockA: MutableBytes
                var blockS: MutableBytes
            }

            internal static func encryptXor(context: EncryptXorContext) {
                setCounter(context.blockA, context.encodeBytes, context.counter)
                aesEncrypt(block: context.blockA, with: context.key, saveTo: context.blockS)
                memxor(context.pointer, context.blockS, context.length)
            }

            internal static func mac(key: Bytes,
                                     pointer: Pointer,
                                     length: Int,
                                     blockB: MutableBytes,
                                     blockX: MutableBytes) {
                var pointer = pointer
                for index in 0..<length {
                    blockB[index] = blockX[index] ^ pointer.pointee
                    pointer = pointer.successor()
                }

                aesEncrypt(block: blockB, with: key, saveTo: blockX)
            }

            internal static func ccmFlags(_ authOctets: Int, _ encodeBytes: Int) -> UInt8 {
                UInt8((((authOctets - 2) / 2) << 3) | (encodeBytes - 1))
            }

            internal static func encodingMask(_ encodeBytesLength: Int) -> UInt {
                UInt((1 << 8 * encodeBytesLength) - 1)
            }

        }

    }

}
