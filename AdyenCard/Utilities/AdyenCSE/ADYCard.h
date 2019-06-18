//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADYCard : NSObject

@property (nonatomic, strong, nullable) NSDate *generationtime;
@property (nonatomic, strong, nullable) NSString *number;
@property (nonatomic, strong, nullable) NSString *holderName;
@property (nonatomic, strong, nullable) NSString *cvc;
@property (nonatomic, strong, nullable) NSString *expiryMonth;
@property (nonatomic, strong, nullable) NSString *expiryYear;

+ (nullable ADYCard *)decode:(NSData *)json error:(NSError * _Nullable *)error;
- (nullable NSData *)encode;

@end

NS_ASSUME_NONNULL_END
