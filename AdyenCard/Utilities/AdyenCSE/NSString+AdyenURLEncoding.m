//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "NSString+AdyenURLEncoding.h"
#import "NSString+AdyenUtil.h"

@implementation NSString (AdyenURLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return [self URLEncodedString];
}

@end
