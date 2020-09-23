//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ObjC_CardEncryptor.h"
#import "ADYAESCCMCryptor.h"

@implementation ObjC_CardEncryptor

+ (NSData *)aesEncrypt:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv {
    NSParameterAssert(data);
    NSParameterAssert(key);
    NSParameterAssert(iv);

    return [ADYAESCCMCryptor encrypt:data withKey:key iv:iv];
}

@end
