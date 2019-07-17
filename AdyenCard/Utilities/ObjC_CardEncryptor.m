//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ObjC_CardEncryptor.h"
#import "AdyenCSE/ADYCard.h"
#import "AdyenCSE/ADYEncrypter.h"

@implementation ObjC_CardEncryptor

+ (NSString *)encryptedNumber:(NSString *)number publicKey:(NSString *)publicKey date:(NSDate *)date {
    ADYCard *card = [ADYCard new];
    card.number = number;
    
    return [ObjC_CardEncryptor encryptCard:card withPublicKey:publicKey date:date];
}

+ (NSString *)encryptedSecurityCode:(NSString *)securityCode publicKey:(NSString *)publicKey date:(NSDate *)date {
    ADYCard *card = [ADYCard new];
    card.cvc = securityCode;
    
    return [ObjC_CardEncryptor encryptCard:card withPublicKey:publicKey date:date];
}

+ (NSString *)encryptedExpiryMonth:(NSString *)expiryMonth publicKey:(NSString *)publicKey date:(NSDate *)date {
    ADYCard *card = [ADYCard new];
    card.expiryMonth = expiryMonth;
    
    return [ObjC_CardEncryptor encryptCard:card withPublicKey:publicKey date:date];
}

+ (NSString *)encryptedExpiryYear:(NSString *)expiryYear publicKey:(NSString *)publicKey date:(NSDate *)date {
    ADYCard *card = [ADYCard new];
    card.expiryYear = expiryYear;
    
    return [ObjC_CardEncryptor encryptCard:card withPublicKey:publicKey date:date];
}

+ (NSString *)encryptedToTokenWithNumber:(NSString *)number
                            securityCode:(NSString *)securityCode
                             expiryMonth:(NSString *)expiryMonth
                              expiryYear:(NSString *)expiryYear
                              holderName:(NSString *)holderName
                               publicKey:(NSString *)publicKey {
    ADYCard *card = [ADYCard new];
    card.number = number;
    card.cvc = securityCode;
    card.expiryMonth = expiryMonth;
    card.expiryYear = expiryYear;
    card.holderName = holderName;
    
    return [ObjC_CardEncryptor encryptCard:card withPublicKey:publicKey date:[NSDate new]];
}

+ (nullable NSString *)encryptCard:(ADYCard *)card withPublicKey:(NSString *)publicKey date:(NSDate *)date {
    card.generationtime = date;
    
    NSData *encodedCard = [card encode];
    
    if (encodedCard) {
        return [ADYEncrypter encrypt:encodedCard publicKeyInHex:publicKey];
    }
    
    return nil;
}

@end
