//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ADYC_AESCCM_TraceLog 0

@interface ADYAESCCMCryptor : NSObject

+ (nullable NSData *)encrypt:(nonnull NSData *)data withKey:(nonnull NSData *)key iv:(nonnull NSData *)iv;

@end

NS_ASSUME_NONNULL_END
