//
//  TWAppConfiguration.h
//  TwintSDK
//
//  Created by Patrick Schmid on 11/05/17.
//  Copyright (c) 2017 Monexio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWAppConfiguration : NSObject

- (nonnull instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithAppURLScheme:(nonnull NSString *)appURLScheme NS_DESIGNATED_INITIALIZER;

@property (nullable, nonatomic) NSString* appDisplayName;
@property (nonnull, nonatomic) NSString* appURLScheme;

@end
