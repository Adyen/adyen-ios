//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADYCryptor : NSObject

/**
 *  Sets encoded message prefix
 *
 *  @param prefix Prefix string, default: ""
 */
+ (void)setMsgPrefix:(nullable NSString *)prefix;


/**
 *  Encrypts the data with AES-CBC using
 *  generated AES256 session key and IV (12)
 *  Encrypts the session key with RSA using
 *  public key (using Keychain)
 *
 *  @param data     data to be encrypted
 *  @param keyInHex Public key in Hex with format "Exponent|Modulus"
 *
 *  @return Fully composed message in format:
 *    - a prefix
 *    - a separator
 *    - RSA encrypted AES key, base64 encoded
 *    - a separator
 *    - a Payload of iv and cipherText, base64 encoded
 *
 *  @see `setMsgPrefix:`
 *  @see `setMsgSeparator:`
 */
+ (nullable NSString *)encrypt:(nonnull NSData *)data publicKeyInHex:(nonnull NSString *)keyInHex;

+ (nullable NSData *)aesEncrypt:(nonnull NSData *)data withKey:(nonnull NSData *)key iv:(nonnull NSData *)iv;
+ (nullable NSData *)rsaEncrypt:(nonnull NSData *)data withKeyInHex:(nonnull NSString *)keyInHex;


+ (nullable NSData *)dataFromHex:(nonnull NSString *)hex;
+ (nullable NSData *)sha1FromStringInHex:(nonnull NSString *)stringInHex;

@end

NS_ASSUME_NONNULL_END
