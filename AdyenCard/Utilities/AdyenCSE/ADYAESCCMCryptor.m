//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#import "ADYAESCCMCryptor.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ADYAESCCMCryptor

#if ADYC_AESCCM_TraceLog
NSData *dh(unsigned char *d) {
    return [NSData dataWithBytes:d length:kCCBlockSizeAES128];
}
#endif


+ (NSData *)encrypt:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv
{
    return [self encrypt:data withKey:key iv:iv tagLength:8];
}

+ (NSData *)encrypt:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv tagLength:(size_t)tagLength {
    return [self encrypt:data withKey:key iv:iv tagLength:tagLength adata:nil];
}

+ (NSData *)encrypt:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv
          tagLength:(size_t)tagLength adata:(NSData *)adata {
    NSParameterAssert(data);
    NSParameterAssert(key);
    NSParameterAssert(iv);
    
    NSMutableData *cipher = [NSMutableData dataWithBytes:data.bytes length:(data.length + tagLength)];
    
    
    size_t LSize = 15 - iv.length;
    ccm_encrypt_message(key.bytes, key.length,
                        tagLength, LSize, (unsigned char *)iv.bytes,
                        (unsigned char *)cipher.mutableBytes, data.length,
                        (unsigned char *)adata.bytes, adata.length);

    
    if (adata) {
        NSMutableData *fullCipher = [NSMutableData dataWithCapacity:(adata.length + cipher.length)];
        [fullCipher appendData:adata];
        [fullCipher appendData:cipher];
        return fullCipher;
    }
    
    return cipher;
}

CCCryptorStatus aes_encrypt(const void *key, size_t kL, unsigned char *bytes, unsigned char *cipher) {
    size_t length = kCCBlockSizeAES128;
    size_t outLength;
    CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES,
                                     kCCOptionECBMode,
                                     key,
                                     kL,
                                     NULL,
                                     bytes,
                                     length,
                                     cipher,
                                     length,
                                     &outLength);
    
    if (result != kCCSuccess) {
        NSLog(@"AES128 Encryption Error");
    }
    return result;
}

#pragma mark - CCM

#define CCM_BLOCKSIZE kCCBlockSizeAES128


#define CCM_FLAGS(A,M,L) (((A > 0) << 6) | (((M - 2)/2) << 3) | (L - 1))

#define CCM_MASK_L(_L) ((1 << 8 * _L) - 1)

#define CCM_SET_COUNTER(A,L,cnt,C) {					\
int i;								\
memset((A) + CCM_BLOCKSIZE - (L), 0, (L));			\
(C) = (cnt) & CCM_MASK_L(L);						\
for (i = CCM_BLOCKSIZE - 1; (C) && (i > (L)); --i, (C) >>= 8)	\
(A)[i] |= (C) & 0xFF;						\
}


// XORs `n` bytes byte-by-byte starting at `y` to the memory area starting at `x`.
static inline void
ccm_memxor(unsigned char *x, const unsigned char *y, size_t n) {
    while(n--) {
        *x ^= *y;
        x++; y++;
    }
}

static inline void
ccm_block0(size_t M,       /* number of auth bytes */
           size_t L,       /* number of bytes to encode message length */
           size_t la,      /* l(a) octets additional authenticated data */
           size_t lm,      /* l(m) message length */
           unsigned char nonce[CCM_BLOCKSIZE],
           unsigned char *result) {
    int i;
    
    result[0] = CCM_FLAGS(la, M, L);
    
    /* copy the nonce */
    memcpy(result + 1, nonce, CCM_BLOCKSIZE - L);
    
    for (i=0; i < L; i++) {
        result[15-i] = lm & 0xff;
        lm >>= 8;
    }
}

static inline void
ccm_encrypt_xor(const void *key, size_t kL,
                size_t L, unsigned long counter,
                unsigned char *msg, size_t len,
                unsigned char A[CCM_BLOCKSIZE],
                unsigned char S[CCM_BLOCKSIZE]) {
    
    static unsigned long counter_tmp;
    
    CCM_SET_COUNTER(A, L, counter, counter_tmp);
    aes_encrypt(key, kL, A, S);
    ccm_memxor(msg, S, len);
}

static inline void
ccm_mac(const void *key, size_t kL,
        unsigned char *msg, size_t len,
        unsigned char B[CCM_BLOCKSIZE],
        unsigned char X[CCM_BLOCKSIZE]) {
    size_t i;
    
    for (i = 0; i < len; ++i)
        B[i] = X[i] ^ msg[i];
    
#if ADYC_AESCCM_TraceLog
    NSLog(@"ccm_mac: %@", dh(B));
#endif
    
    aes_encrypt(key, kL, B, X);

#if ADYC_AESCCM_TraceLog
    NSLog(@"ccm_mac e: %@", dh(X));
#endif
}

#define dtls_int_to_uint16(Field,Value) do {			\
  *(unsigned char*)(Field) = ((Value) >> 8) & 0xff;		\
  *(((unsigned char*)(Field))+1) = ((Value) & 0xff);		\
  } while(0)

/**
 * Creates the CBC-MAC for the additional authentication data that
 * is sent in cleartext. The result is written to `X`.
 *
 * @param key The AES key
 * @param kL  The AES key length
 * @param msg  The message starting with the additional authentication data.
 * @param la   The number of additional authentication bytes in msg.
 * @param B    The input buffer for crypto operations. When this function
 *             is called, B must be initialized with B0 (the first
 *             authentication block.
 * @param X    The output buffer where the result of the CBC calculation
 *             is placed.
 */
static void
ccm_add_auth_data(const void *key, size_t kL,
              const unsigned char *msg, size_t la,
              unsigned char B[CCM_BLOCKSIZE],
              unsigned char X[CCM_BLOCKSIZE]) {
    size_t i,j;
    
    aes_encrypt(key, kL, B, X);
    memset(B, 0, CCM_BLOCKSIZE);
    
    if (!la)
        return;
    

    /* Here we are building for small devices and thus
     * anticipate that the number of additional authentication bytes
     * will not exceed 65280 bytes (0xFF00) and we can skip the
     * workarounds required for j=6 and j=10 on devices with a word size
     * of 32 bits or 64 bits, respectively.
     */
    
    assert(la < 0xFF00);
    j = 2;
    dtls_int_to_uint16(B, la);
    
    i = MIN(CCM_BLOCKSIZE - j, la);
    memcpy(B + j, msg, i);
    la -= i;
    msg += i;
    
    ccm_memxor(B, X, CCM_BLOCKSIZE);
    
    aes_encrypt(key, kL, B, X);
    
    while (la > CCM_BLOCKSIZE) {
        for (i = 0; i < CCM_BLOCKSIZE; ++i)
            B[i] = X[i] ^ *msg++;
        la -= CCM_BLOCKSIZE;
        
        aes_encrypt(key, kL, B, X);
    }
    
    if (la) {
        memset(B, 0, CCM_BLOCKSIZE);
        memcpy(B, msg, la);
        ccm_memxor(B, X, CCM_BLOCKSIZE);
        
        aes_encrypt(key, kL, B, X);
    } 
}

/**
 * Authenticates and encrypts a message using AES in CCM mode. Please
 * see also RFC 3610 for the meaning of  M,  L,  lm and  la.
 *
 * @param key   The AES key
 * @param kL    The AES key length
 * @param M     The number of authentication octets.
 * @param L     The number of bytes used to encode the message length.
 * @param nonce The nonce value to use. You must provide  CCM_BLOCKSIZE
 *              nonce octets, although only the first  16 -  L are used.
 * @param msg   The message to encrypt. The first  la octets are additional
 *              authentication data that will be cleartext. Note that the
 *              encryption operation modifies the contents of  msg and adds
 *              M bytes MAC. Therefore, the buffer must be at least
 *              lm +  M bytes large.
 * @param lm    The actual length of  msg.
 * @param aad   A pointer to the additional authentication data (can be  NULL if
 *              la is zero).
 * @param la    The number of additional authentication octets (may be zero).
 * @return length
 */
size_t
ccm_encrypt_message(const void *key, size_t kL,
                    size_t M, size_t L,
                    unsigned char nonce[CCM_BLOCKSIZE],
                    unsigned char *msg, size_t lm,
                    const unsigned char *aad, size_t la) {
    size_t i, len;
    unsigned long counter_tmp;
    unsigned long counter = 1; /// @bug does not work correctly on ia32 when lm >= 2^16
    unsigned char A[CCM_BLOCKSIZE]; /* A_i blocks for encryption input */
    unsigned char B[CCM_BLOCKSIZE]; /* B_i blocks for CBC-MAC input */
    unsigned char S[CCM_BLOCKSIZE]; /* S_i = encrypted A_i blocks */
    unsigned char X[CCM_BLOCKSIZE]; /* X_i = encrypted B_i blocks */
    
    len = lm;			/* save original length */
    /* create the initial authentication block B0 */
    ccm_block0(M, L, la, lm, nonce, B);
    
#if ADYC_AESCCM_TraceLog
    NSLog(@"ccm_block0: %@", dh(B));
#endif
    
    //aes_encrypt(key, kL, B, X);
    //memset(B, 0, CCM_BLOCKSIZE);
    ccm_add_auth_data(key, kL, aad, la, B, X);
    
#if ADYC_AESCCM_TraceLog
    NSLog(@"ccm_add_auth_data: B: %@ X: %@", dh(B), dh(X));
#endif
    
    /* initialize block template */
    A[0] = L-1;
    
    // copy the nonce
    memcpy(A + 1, nonce, CCM_BLOCKSIZE - L);
    
    while (lm >= CCM_BLOCKSIZE) {
        // calculate MAC
        ccm_mac(key, kL, msg, CCM_BLOCKSIZE, B, X);
        
        
        // encrypt
        ccm_encrypt_xor(key, kL, L, counter, msg, CCM_BLOCKSIZE, A, S);
        
        // update local pointers
        lm -= CCM_BLOCKSIZE;
        msg += CCM_BLOCKSIZE;
        counter++;
    }
    
    if (lm) {
        /* Calculate MAC. The remainder of B must be padded with zeroes, so
         * B is constructed to contain X ^ msg for the first lm bytes (done in
         * mac() and X ^ 0 for the remaining CCM_BLOCKSIZE - lm bytes
         * (i.e., we can use memcpy() here).
         */
        memcpy(B + lm, X + lm, CCM_BLOCKSIZE - lm);
        ccm_mac(key, kL, msg, lm, B, X);
        
        // encrypt
        ccm_encrypt_xor(key, kL, L, counter, msg, lm, A, S);
        
        // update local pointers
        msg += lm;
    }
    
    // calculate S_0
    CCM_SET_COUNTER(A, L, 0, counter_tmp);
    aes_encrypt(key, kL, A, S);
    
    for (i = 0; i < M; ++i)
        *msg++ = X[i] ^ S[i];
    
    return len + M;
}



@end
