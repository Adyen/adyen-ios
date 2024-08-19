//
//  Twint.h
//  TwintSDK
//
//  Created by Loic Pfister on 06/11/14.
//  Copyright (c) 2014 Monexio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwintSDK/TWAppConfiguration.h>

@interface Twint : NSObject

typedef void(^TWResponseHandler)(NSError *error);

typedef void (^TWInstalledAppFetchHandler)(NSArray<TWAppConfiguration *>* installedAppConfigurations);

typedef void (^TWAppChooserSelectionHandler)(TWAppConfiguration* selectedConfiguration);

typedef void (^TWAppChooserCancelHandler)(void);

/** 
 * Calls the Twint app to execute a payment for a known code
 * @param code The transaction code
 * @param appConfiguration The app configuration with which the payment will be executed
 * @param callbackAppScheme The callback app scheme invoked once the Twint app is done with the payment
 * @return Returns a NSError object which is nil in case of successful call
 */
+ (NSError*)payWithCode:(NSString*)code appConfiguration:(TWAppConfiguration *)appConfiguration callback:(NSString*)callbackAppScheme;

/**
 * This method starts the registration process in the Twint app with a given code
 * @param code The transaction code
 * @param appConfiguration The app configuration with which the registration will be executed
 * @param callbackAppScheme The callback app scheme invoked once the Twint app is done with the registration
 * @return Returns a NSError object which is nil in case of successful call
 */
+ (NSError *)registerForUOFWithCode:(NSString *)code appConfiguration:(TWAppConfiguration *)appConfiguration callback:(NSString *)callbackAppScheme;

/**
 * Fetches all available app configurations from a remote and returns all that are potentially installed on the device. If there is an error during the fetch, the cache will be used. If there is nothing in the cache yet, all Twint apps will be probed until one is found that is installed.
 * @param maxIssuerNumber The issuer number of the highest scheme you listed under `LSApplicationQueriesSchemes`. E.g. pass 39, if you listed all schemes from "twint-issuer1" up to and including "twint-issuer39". The value is clamped between 0 and 39.
 * @param completionHandler The block which will be executed once the fetch or probing is completed
 *
 * All apps above "twint-issuer39" will always be returned if one of these apps is installed. For this to work, `LSApplicationQueriesSchemes` must include "twint-extended".
 *
 * If you configure any `maxIssuerNumber` below 39, the result will always contain all apps above `maxIssuerNumber` up to and including 39, even if none of them are installed. Additionally, if the fetch fails and the cache is empty, none of these apps will be found when probing.
 */
+ (void)fetchInstalledAppConfigurationsWithMaxIssuerNumber:(NSInteger)maxIssuerNumber completionHandler:(TWInstalledAppFetchHandler)completionHandler;

/**
 * The returned UIAlertController will show the given app configurations and a cancel button. After pressing a button, the corresponding handler will be called.
 * @param selectionHandler The block which will be executed once a selection of a Twint app has been made by the user
 * @param cancelHandler The block which will be executed once the user hit the cancel button
 */
+ (UIAlertController *)controllerForAppConfigurations:(NSArray<TWAppConfiguration *> *)installedAppConfigurations
						 selectedConfigurationHandler:(TWAppChooserSelectionHandler)selectionHandler
										cancelHandler:(TWAppChooserCancelHandler)cancelHandler;

/** 
 * Convenience method to handle the callback from the Twint app
 * @param url The url sent by the Twint app
 * @param handler The block which will be executed once the callback has been analyzed
 * @return Returns YES if the library can handle the URL/callback, NO otherwise
 */
+ (BOOL)handleOpenURL:(NSURL*)url withResponseHandler:(TWResponseHandler)handler;

/**
 * Returns the SDK version
 * @return Returns the SDK version string
 */
+ (NSString*)version;

@end
