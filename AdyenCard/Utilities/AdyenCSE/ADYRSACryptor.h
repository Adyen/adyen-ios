//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADYRSACryptor : NSObject

+ (nullable NSData *)encrypt:(nonnull NSData *)data withKeyInHex:(nonnull NSString *)keyInHex;

+ (BOOL)deleteRSAPublicKeyWithAppTag:(nonnull NSString*)appTag;

@end

NS_ASSUME_NONNULL_END
