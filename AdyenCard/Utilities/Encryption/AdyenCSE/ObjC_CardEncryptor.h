//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

@interface ObjC_CardEncryptor : NSObject

#pragma mark - Wrappers

+ (NSData *)aesEncrypt:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv;

@end
