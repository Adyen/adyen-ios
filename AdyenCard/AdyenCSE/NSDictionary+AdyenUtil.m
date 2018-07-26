//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "NSDictionary+AdyenUtil.h"
#import "NSString+AdyenUtil.h"

@implementation NSDictionary (AdyenUtil)

- (NSString *)encodeFormData {
    return [self ady_encodeFormData];
}

- (NSString *)ady_encodeFormData {
    NSMutableString* s = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL *stop) {
        if(s.length) {
            [s appendString:@"&"];
        }
        [s appendFormat:@"%@=%@", [key ady_URLEncodedString], [value ady_URLEncodedString]];
    }];
    return s;
}

@end
