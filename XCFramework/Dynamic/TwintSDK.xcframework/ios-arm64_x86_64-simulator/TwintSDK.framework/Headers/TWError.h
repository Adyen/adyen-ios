//
//  TWError.h
//  TwintSDK
//
//  Created by Loic Pfister on 12/11/14.
//  Copyright (c) 2014 Monexio. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const TwintSDKDomain;

/*
 @typedef NS_ENUM (NSUInteger, TWErrorCode)
 @abstract Error codes returned by the TwintSDK in NSError.
 
 @discussion
 These are valid only in the scope of TwintSDKDomain.
 */
typedef NS_ENUM(NSInteger, TWErrorCode) {
    /*
     Like nil for TWErrorCode values, represents an error code that
     has not been initialized yet.
     */
	/* Payment was successful */
    TW_B_SUCCESS,
    
	/* Payment failed for various reason */
    TW_B_ERROR,
    
    /* The TWINT application is not installed */
    TW_B_APP_NOT_INSTALLED,
    
    /* The format of the code is invalid */
    TW_T_CODE_FORMAT_INVALID,
    
    /* The URL schema format is wrong */
    TW_IOS_SCHEMA_URL_INVALID
};
