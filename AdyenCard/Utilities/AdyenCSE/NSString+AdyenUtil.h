//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AdyenUtil)

- (BOOL)isHexString DEPRECATED_MSG_ATTRIBUTE("Use -ady_isHexString instead.");
- (BOOL)ady_isHexString;

- (nullable NSString *)URLEncodedString DEPRECATED_MSG_ATTRIBUTE("Use -ady_URLEncodedString instead.");
- (nullable NSString *)ady_URLEncodedString;

@end

NS_ASSUME_NONNULL_END
