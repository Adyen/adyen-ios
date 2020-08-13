//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ADYCard.h"

@interface ADYCard ()
@property (readonly) NSDateFormatter* dateFormatter;
@end

@implementation ADYCard

- (NSData *)encode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *key in @[@"number", @"holderName", @"cvc", @"expiryMonth", @"expiryYear"]) {
        if ([self valueForKey:key]) {
            dict[key] = [self valueForKey:key];
        }
    }
    
    if (self.generationtime) {
        dict[@"generationtime"] = [self.dateFormatter stringFromDate:self.generationtime];
    }
    
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

- (NSDateFormatter *)dateFormatter {
    static dispatch_once_t once;
    static NSDateFormatter *instance;
    dispatch_once(&once, ^{
        instance = [[NSDateFormatter alloc] init];
        instance.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        instance.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        instance.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        instance.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    });
    return instance;
}

@end
