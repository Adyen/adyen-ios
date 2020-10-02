//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Security

/// Set of helpers for RSA encryption.
internal enum RSACryptor {

    /**
     * Encrypt with RSA public key
     *
     * - Parameters:
     *   - data: The data to encrypt.
     *   - exponent: Modulus of the public key.
     *   - modulus: Exponent of the public key.
     *
     *  - Returns
     *      Encrypted data or nil if modulus and exponent is invalid.
     */
    public static func encrypt(data: Data, exponent: String, modulus: String) -> Data? {
        let fingerprint = "\(exponent)|\(modulus)".sha1()
        
        if let publicKey = self.loadRSAPublicKeyRef(appTag: fingerprint) {
            return self.encrypt(original: data, publicKey: publicKey)
        }

        guard let modulusHex = modulus.hexadecimal, let exponentHex = exponent.hexadecimal else { return nil }

        adyenPrint("Adding PublicKey to Keystore with fingerprint: \(fingerprint)")
        
        let pubKeyData = self.generateRSAPublicKey(with: modulusHex, exponent: exponentHex)
        self.saveRSA(publicKey: pubKeyData, appTag: fingerprint, overwrite: true)
        
        guard let publicKey = self.loadRSAPublicKeyRef(appTag: fingerprint) else {
            adyenPrint("Problem obtaining SecKey")
            return nil
        }
        
        return self.encrypt(original: data, publicKey: publicKey)
    }

    private static func encrypt(original: Data, publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?

        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, .rsaEncryptionPKCS1) else {
            fatalError("Can't use this algorithm with this key!")
        }

        if let encrypted = SecKeyCreateEncryptedData(publicKey, .rsaEncryptionPKCS1, original as CFData, &error) {
            return encrypted as NSData as Data
        }

        if let err: Error = error?.takeRetainedValue() {
            print("encryptData error \(err.localizedDescription)")

        }
        return nil
    }
    
    @discardableResult
    private static func saveRSA(publicKey: Data, appTag: String, overwrite: Bool) -> Bool {
        guard let appTagData = appTag.data(using: .utf8) else { return false }
        
        let keychainQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag: appTagData as NSData as CFData,
            kSecValueData: publicKey as NSData as CFData,
            kSecReturnPersistentRef: kCFBooleanTrue!
        ]
        
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if status == noErr {
            return true
        } else if status == errSecDuplicateItem, overwrite {
            return self.updateRSA(publicKey: publicKey, appTag: appTag)
        } else {
            print("result = \(status)")
        }
        
        return false
    }
    
    @discardableResult
    private static func updateRSA(publicKey: Data, appTag: String) -> Bool {
        guard let appTagData = appTag.data(using: .utf8) else { return false }
        
        let keychainQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag: appTagData as NSData as CFData
        ]
        
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, nil)
        if status == noErr {
            let valueQuery: [CFString: Any] = [
                kSecValueData: publicKey as NSData as CFData
            ]
            
            let status = SecItemUpdate(keychainQuery as CFDictionary, valueQuery as CFDictionary)
            if status != noErr {
                print("result = \(status)")
                return false
            }
            return true
        } else {
            print("result = \(status)")
        }
        
        return false
    }
    
    @discardableResult
    public static func deleteRSA(appTag: String) -> Bool {
        guard let appTagData = appTag.data(using: .utf8) else { return false }
        
        let keychainQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag: appTagData as NSData as CFData
        ]
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        if status != noErr {
            print("result = \(status)")
        }
        
        return status == noErr
    }
    
    /*
     * returned value(SecKeyRef) should be released with CFRelease() function after use.
     *
     */
    private static func loadRSAPublicKeyRef(appTag: String) -> SecKey? {
        guard let appTagData = appTag.data(using: .utf8) else { return nil }
        
        let keychainQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag: appTagData as NSData as CFData,
            kSecReturnRef: true
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        if let dataTypeRef = dataTypeRef, status == noErr {
            return (dataTypeRef as! SecKey) // swiftlint:disable:this force_cast
        } else {
            print("result = \(status)")
            return nil
        }
    }
    
    /// https://github.com/henrinormak/Heimdall/blob/master/Heimdall/Heimdall.swift
    private static func generateRSAPublicKey(with modulus: Data, exponent: Data) -> Data {
        var modulusBytes = modulus.asBytes
        let exponentBytes = exponent.asBytes
        
        // Make sure modulus starts with a 0x00
        if let prefix = modulusBytes.first, prefix != 0x00 {
            modulusBytes.insert(0x00, at: 0)
        }
        
        // Lengths
        let modulusLengthOctets = modulusBytes.count.encodedOctets()
        let exponentLengthOctets = exponentBytes.count.encodedOctets()
        
        // Total length is the sum of components + types
        let totalLengthOctets = (modulusLengthOctets.count + modulusBytes.count +
            exponentLengthOctets.count + exponentBytes.count + 2).encodedOctets()
        
        // Combine the two sets of data into a single container
        var builder: [CUnsignedChar] = []
        let data = NSMutableData()
        
        // Container type and size
        builder.append(0x30)
        builder.append(contentsOf: totalLengthOctets)
        data.append(builder, length: builder.count)
        builder.removeAll(keepingCapacity: false)
        
        // Modulus
        builder.append(0x02)
        builder.append(contentsOf: modulusLengthOctets)
        data.append(builder, length: builder.count)
        builder.removeAll(keepingCapacity: false)
        data.append(modulusBytes, length: modulusBytes.count)
        
        // Exponent
        builder.append(0x02)
        builder.append(contentsOf: exponentLengthOctets)
        data.append(builder, length: builder.count)
        data.append(exponentBytes, length: exponentBytes.count)
        
        return Data(bytes: data.bytes, count: data.length)
    }
    
}

private extension Data {
    
    var asBytes: [CUnsignedChar] {
        let start = (self as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: self.count)
        let count: Int = self.count / MemoryLayout<CUnsignedChar>.size
        return [CUnsignedChar](UnsafeBufferPointer<CUnsignedChar>(start: start, count: count))
    }
    
}

private extension NSInteger {
    
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)]
        }
        
        // Long form
        let index = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(index + 0x80)]
        
        for _ in 0..<index {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
    
}
