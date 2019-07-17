//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

@interface ObjC_CardEncryptor : NSObject

+ (nullable NSString *)encryptedNumber:(nullable NSString *)number
                             publicKey:(nonnull NSString *)publicKey
                                  date:(nonnull NSDate *)date;

+ (nullable NSString *)encryptedSecurityCode:(nullable NSString *)securityCode
                                   publicKey:(nonnull NSString *)publicKey
                                        date:(nonnull NSDate *)date;

+ (nullable NSString *)encryptedExpiryMonth:(nullable NSString *)expiryMonth
                                  publicKey:(nonnull NSString *)publicKey
                                       date:(nonnull NSDate *)date;

+ (nullable NSString *)encryptedExpiryYear:(nullable NSString *)expiryYear
                                 publicKey:(nonnull NSString *)publicKey
                                      date:(nonnull NSDate *)date;

+ (nullable NSString *)encryptedToTokenWithNumber:(nullable NSString *)number
                                     securityCode:(nullable NSString *)securityCode
                                      expiryMonth:(nullable NSString *)expiryMonth
                                       expiryYear:(nullable NSString *)expiryYear
                                       holderName:(nullable NSString *)holderName
                                        publicKey:(nonnull NSString *)publicKey;

@end
