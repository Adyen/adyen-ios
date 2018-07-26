//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ADYRSACryptor.h"
#import <Security/Security.h>
#import "ADYCryptor.h"

@import Security;

@implementation ADYRSACryptor

+ (NSData *)encrypt:(NSData *)data withKeyInHex:(NSString *)keyInHex {
    NSParameterAssert(data);
    NSParameterAssert(keyInHex);
    
    NSString *fingerprint = [[ADYCryptor sha1FromStringInHex:keyInHex] base64EncodedStringWithOptions:0];

    SecKeyRef publicKey = [self loadRSAPublicKeyRefWithAppTag:fingerprint];
    if (!publicKey) {
        
        NSArray *tokens = [keyInHex componentsSeparatedByString:@"|"];
        if (tokens.count != 2) {
            return nil;
        }
        
        NSData *exponent = [ADYCryptor dataFromHex:tokens[0]];
        NSData *modulus  = [ADYCryptor dataFromHex:tokens[1]];
        
        if (!exponent || !modulus) {
            return nil;
        }
        
        NSLog(@"Adding PublicKey to Keystore with fingerprint: %@", fingerprint);
        
        NSData *pubKeyData = [self generateRSAPublicKeyWithModulus:modulus exponent:exponent];
        [self saveRSAPublicKey:pubKeyData appTag:fingerprint overwrite:YES];
        publicKey = [self loadRSAPublicKeyRefWithAppTag:fingerprint];
    }
    
    if (!publicKey) {
        NSLog(@"Problem obtaining SecKeyRef");
        return nil;
    }
    
    return [self encrypt:data RSAPublicKey:publicKey padding:kSecPaddingPKCS1];
}


// https://github.com/meinside/iphonelib/blob/master/security/CryptoUtil.m

+ (NSData *)generateRSAPublicKeyWithModulus:(NSData*)modulus exponent:(NSData*)exponent
{
    const uint8_t DEFAULT_EXPONENT[] = {0x01, 0x00, 0x01,};	//default: 65537
    const uint8_t UNSIGNED_FLAG_FOR_BYTE = 0x81;
    const uint8_t UNSIGNED_FLAG_FOR_BYTE2 = 0x82;
    const uint8_t UNSIGNED_FLAG_FOR_BIGNUM = 0x00;
    const uint8_t SEQUENCE_TAG = 0x30;
    const uint8_t INTEGER_TAG = 0x02;
    
    uint8_t* modulusBytes = (uint8_t*)[modulus bytes];
    uint8_t* exponentBytes = (uint8_t*)(exponent == nil ? DEFAULT_EXPONENT : [exponent bytes]);
    
    //(1) calculate lengths
    //- length of modulus
    int lenMod = (int)[modulus length];
    if(modulusBytes[0] >= 0x80)
        lenMod ++;	//place for UNSIGNED_FLAG_FOR_BIGNUM
    int lenModHeader = 2 + (lenMod >= 0x80 ? 1 : 0) + (lenMod >= 0x0100 ? 1 : 0);
    //- length of exponent
    int lenExp = exponent == nil ? sizeof(DEFAULT_EXPONENT) : (int)[exponent length];
    int lenExpHeader = 2;
    //- length of body
    int lenBody = lenModHeader + lenMod + lenExpHeader + lenExp;
    //- length of total
    int lenTotal = 2 + (lenBody >= 0x80 ? 1 : 0) + (lenBody >= 0x0100 ? 1 : 0) + lenBody;
    
    int index = 0;
    uint8_t* byteBuffer = malloc(sizeof(uint8_t) * lenTotal);
    memset(byteBuffer, 0x00, sizeof(uint8_t) * lenTotal);
    
    //(2) fill up byte buffer
    //- sequence tag
    byteBuffer[index ++] = SEQUENCE_TAG;
    //- total length
    if(lenBody >= 0x80)
        byteBuffer[index ++] = (lenBody >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenBody >= 0x0100)
    {
        byteBuffer[index ++] = (uint8_t)(lenBody / 0x0100);
        byteBuffer[index ++] = lenBody % 0x0100;
    }
    else
        byteBuffer[index ++] = lenBody;
    //- integer tag
    byteBuffer[index ++] = INTEGER_TAG;
    //- modulus length
    if(lenMod >= 0x80)
        byteBuffer[index ++] = (lenMod >= 0x0100 ? UNSIGNED_FLAG_FOR_BYTE2 : UNSIGNED_FLAG_FOR_BYTE);
    if(lenMod >= 0x0100)
    {
        byteBuffer[index ++] = (int)(lenMod / 0x0100);
        byteBuffer[index ++] = lenMod % 0x0100;
    }
    else
        byteBuffer[index ++] = lenMod;
    //- modulus value
    if(modulusBytes[0] >= 0x80)
        byteBuffer[index ++] = UNSIGNED_FLAG_FOR_BIGNUM;
    memcpy(byteBuffer + index, modulusBytes, sizeof(uint8_t) * [modulus length]);
    index += [modulus length];
    //- exponent length
    byteBuffer[index ++] = INTEGER_TAG;
    byteBuffer[index ++] = lenExp;
    //- exponent value
    memcpy(byteBuffer + index, exponentBytes, sizeof(uint8_t) * lenExp);
    index += lenExp;
    
    if(index != lenTotal)
        NSLog(@"lengths mismatch: index = %d, lenTotal = %d", index, lenTotal);
    
    NSMutableData* buffer = [NSMutableData dataWithBytes:byteBuffer length:lenTotal];
    free(byteBuffer);
    
    return buffer;
}

+ (BOOL)saveRSAPublicKey:(NSData*)publicKey appTag:(NSString *)appTag overwrite:(BOOL)overwrite
{
    
    NSDictionary *query = nil;
    query = @{
          (__bridge id)kSecClass:               (__bridge id)kSecClassKey,
          (__bridge id)kSecAttrKeyType:         (__bridge id)kSecAttrKeyTypeRSA,
          (__bridge id)kSecAttrKeyClass:        (__bridge id)kSecAttrKeyClassPublic,
          (__bridge id)kSecAttrApplicationTag:  [appTag dataUsingEncoding:NSUTF8StringEncoding],
          (__bridge id)kSecValueData:           publicKey,
          (__bridge id)kSecReturnPersistentRef: @(YES)
          };
    
    CFDataRef ref;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&ref);
    
    
    if (status == noErr) {
        return YES;
    } else if(status == errSecDuplicateItem && overwrite == YES) {
        return [self updateRSAPublicKey:publicKey appTag:appTag];
    } else {
        NSLog(@"result = %d", (int)status);
    }
    
    return NO;
}

+ (BOOL)updateRSAPublicKey:(NSData*)publicKey appTag:(NSString*)appTag
{
    NSDictionary *query = nil;
    query = @{
              (__bridge id)kSecClass:               (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrKeyType:         (__bridge id)kSecAttrKeyTypeRSA,
              (__bridge id)kSecAttrKeyClass:        (__bridge id)kSecAttrKeyClassPublic,
              (__bridge id)kSecAttrApplicationTag:  [appTag dataUsingEncoding:NSUTF8StringEncoding]
              };
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL); //don't need public key ref
    
    if(status == noErr)
    {
        query = @{
                  (__bridge id)kSecClass:               (__bridge id)kSecClassKey,
                  (__bridge id)kSecAttrKeyType:         (__bridge id)kSecAttrKeyTypeRSA,
                  (__bridge id)kSecAttrKeyClass:        (__bridge id)kSecAttrKeyClassPublic,
                  (__bridge id)kSecAttrApplicationTag:  [appTag dataUsingEncoding:NSUTF8StringEncoding]
                  };
        status = SecItemUpdate((__bridge CFDictionaryRef)query,
                               (__bridge CFDictionaryRef)@{(__bridge id)kSecValueData: publicKey});
        
        NSLog(@"result = %d", (int)status);
        
        return status == noErr;
    } else {
        NSLog(@"result = %d", (int)status);
    }
    return NO;
}

+ (BOOL)deleteRSAPublicKeyWithAppTag:(NSString*)appTag
{
    NSDictionary *query = nil;
    query = @{
              (__bridge id)kSecClass:               (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrKeyType:         (__bridge id)kSecAttrKeyTypeRSA,
              (__bridge id)kSecAttrKeyClass:        (__bridge id)kSecAttrKeyClassPublic,
              (__bridge id)kSecAttrApplicationTag:  [appTag dataUsingEncoding:NSUTF8StringEncoding]
              };
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status != noErr) NSLog(@"result = %d", (int)status);

    return status == noErr;
}

/*
 * returned value(SecKeyRef) should be released with CFRelease() function after use.
 *
 */
+ (SecKeyRef)loadRSAPublicKeyRefWithAppTag:(NSString*)appTag
{
    NSDictionary *query = nil;
    query = @{
              (__bridge id)kSecClass:               (__bridge id)kSecClassKey,
              (__bridge id)kSecAttrKeyType:         (__bridge id)kSecAttrKeyTypeRSA,
              (__bridge id)kSecAttrKeyClass:        (__bridge id)kSecAttrKeyClassPublic,
              (__bridge id)kSecAttrApplicationTag:  [appTag dataUsingEncoding:NSUTF8StringEncoding],
              (__bridge id)kSecReturnRef:           @(YES)
              };
    
    SecKeyRef publicKeyRef;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&publicKeyRef);
    
    if (status == noErr) {
        return publicKeyRef;
    } else {
        NSLog(@"result = %d", (int)status);
        return NULL;
    }
}

/**
 * encrypt with RSA public key
 * 
 * padding = kSecPaddingPKCS1 / kSecPaddingNone
 * 
 */
+ (NSData *)encrypt:(NSData *)original RSAPublicKey:(SecKeyRef)publicKey padding:(SecPadding)padding
{
    @try
    {
        size_t encryptedLength = SecKeyGetBlockSize(publicKey);
        uint8_t encrypted[encryptedLength];
        
        OSStatus status = SecKeyEncrypt(publicKey, 
                                        padding, 
                                        original.bytes,
                                        original.length,
                                        encrypted, 
                                        &encryptedLength);
        if (status == noErr) {
            NSData *encryptedData = [[NSData alloc] initWithBytes:(const void*)encrypted length:encryptedLength];
            return encryptedData;
        } else {
            NSLog(@"result = %d", (int)status);
            return nil;
        }
    }
    @catch (NSException * e)
    {
        //do nothing
        NSLog(@"exception: %@", [e reason]);
    }
    return nil;
}

@end
