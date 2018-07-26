//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "NSString+AdyenUtil.h"

@implementation NSString (AdyenUtil)

- (BOOL)isHexString {
    return [self ady_isHexString];
}

- (BOOL)ady_isHexString {
    for(NSUInteger l=0; l<self.length; l++) {
        unichar c = [self characterAtIndex:l];
        if(![self isHexChar:c]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isHexChar:(unichar)c {
    return (c >= '0' && c <= '9') ||
           (c >= 'a' && c <= 'f') ||
           (c >= 'A' && c <= 'F');
}

- (NSString *)URLEncodedString {
    return [self ady_URLEncodedString];
}

- (NSString *)ady_URLEncodedString {
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"] invertedSet];
    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
