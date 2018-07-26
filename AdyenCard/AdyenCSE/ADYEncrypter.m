//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ADYEncrypter.h"


@implementation ADYEncrypter

+ (void)initialize {
    [self setMsgPrefix:@"adyenan0_1_1"];
}

+ (NSString *)encrypt:(NSData *)data publicKeyInHex:(NSString *)keyInHex {    
    return [super encrypt:data publicKeyInHex:keyInHex];
}

@end
