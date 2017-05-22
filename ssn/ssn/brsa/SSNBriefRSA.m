//
//  SSNBriefRSA.m
//  ssn
//
//  Created by fengqu on 2017/5/21.
//  Copyright © 2017年 lingminjun. All rights reserved.
//

#import "SSNBriefRSA.h"
#import "ssninteger.h"

#define BRIEF_EXCEPTION(xx) [NSException exceptionWithName:@"Brief-RSA" reason:(xx) userInfo:nil];

@interface SSNBriefRSAKey : NSObject
@property(nonatomic) int64_t n;
@property(nonatomic) int64_t v;
@end

@implementation SSNBriefRSAKey
@end

@implementation SSNBriefRSA

//是否为质数
+ (BOOL) checkPrime:(int64_t) value {
    for (int64_t i = 2; i < value; i++) {
        if (value%i == 0) {return false;}
    }
    return true;
}

//获取质数
+ (int) getRandom:(int) from to:(int) to {
    int max=to;
    int min=from;
    return min + (int) (arc4random() * (max-min+1));
}

//获取质数
+ (int64_t) getPrime:(int64_t) from to:(int64_t) to {
    int64_t max=to;
    int64_t min=from;
    int64_t prime = 0;
    do {
        prime = min + (int64_t) (arc4random() * (max-min+1));
    } while (![self checkPrime:prime]);
    return prime;
}

+ (void) genRSA:(int64_t) from to:(int64_t) to {
    int64_t p = [self getPrime:from to:to];
    int64_t q = [self getPrime:from to:to];
    while (p == q) {
        q = [self getPrime:from to:to];
    }
    
    //        System.out.println("p = " + p + "; q = " +q);
    if (1.0f * p * q >= LLONG_MAX) {
        @throw BRIEF_EXCEPTION(@"Cannot exceed a maximum of int64_t");
    }
    int64_t n = p*q;//n的长度就是密钥长度
    //        System.out.println("n = p*q = " + n);
    int64_t fn = (p-1)*(q-1);
    //        System.out.println("ψ(n) = ψ(p)*ψ(q) = (p-1)(q-1) = " + fn);
    //随机选择一个整数e，条件是1< e < φ(n)，且e与φ(n) 互质。
    int64_t e = 65537l;
    if (e >= fn) {//防止超过
        e = [self getPrime:2 to:(fn - 1)];
    }
    
    //        System.out.println("1< e < φ(n)，且e与φ(n)互质 e = " + e);
    
    //求解
    int k = -1;//寻找倍数
    int64_t d = 0ll;
    do {
        SSNBInteger bfn,bk,ed,one,be,mod,bd;
        ssn_long_to_bigInt(fn, &bfn);
        ssn_long_to_bigInt(-k, &bk);
        ssn_long_to_bigInt(1, &one);
        ssn_long_to_bigInt(e, &be);
        
        ssn_bigint_mul(&bfn, &bk, &ed);
        ssn_bigint_add(&ed, &one, &ed);
        
        ssn_bigint_mod(&ed, &be, &mod);
        
//        BigInteger mod = ed.mod(BigInteger.valueOf(e));
        const int64_t tmod = ssn_bigint_to_long(&mod);
        if (tmod == 0ll) {
            ssn_bigint_div(&ed, &be, &bd, &mod);
            //d = ed.divide(BigInteger.valueOf(e)).int64_tValue();//
            d = ssn_bigint_to_long(&bd);
            break;
        }
        k--;
    } while (true);
    
    
    //将n和e封装成公钥，
    NSLog(@"rsa pub key:(n,e) = (%lld,%lld) = %@",n,e,[self combinedKey:n key:e]);
    //将n和d封装成私钥。
    NSLog(@"rsa pri key:(n,e) = (%lld,%lld) = %@",n,d,[self combinedKey:n key:d]);
}

+ (NSString *)combinedKey:(int64_t)a key:(int64_t) b {
    NSString *str = [NSString stringWithFormat:@"%016llx+%016llx",a,b];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [data base64EncodedDataWithOptions:0];
    return [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
}

+ (SSNBriefRSAKey *)separateKey:(NSString *)key {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:key options:0];
    NSString *base64Str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    NSArray<NSString *> *strs = [base64Str componentsSeparatedByString:@"+"];
    SSNBriefRSAKey *rsakey = [[SSNBriefRSAKey alloc] init];
    rsakey.n = strtoll([[strs objectAtIndex:0] UTF8String], NULL, 16);
    rsakey.v = strtoll([[strs objectAtIndex:1] UTF8String], NULL, 16);
    return rsakey;
}

//+ (NSString *)encrypt:(NSString*) pubKey data:(NSData *)ms {
//    SSNBriefRSAKey *key = [self separateKey:pubKey];
//    return [self encryptN:key.n E:key.v data:ms];
//}
//
//+ (NSData* )decrypt:(NSString*)priKey data:(NSString *)cs {
//    SSNBriefRSAKey *key = [self separateKey:priKey];
//    return [self decryptN:key.n D:key.v data:cs];
//}

+ (int64_t)dataCRC32:(NSData *)data {
    uint32_t *table = malloc(sizeof(uint32_t) * 256);
    uint32_t crc = 0xffffffff;
    uint8_t *bytes = (uint8_t *)[data bytes];
    
    for (uint32_t i=0; i<256; i++) {
        table[i] = i;
        for (int j=0; j<8; j++) {
            if (table[i] & 1) {
                table[i] = (table[i] >>= 1) ^ 0xedb88320;
            } else {
                table[i] >>= 1;
            }
        }
    }
    
    for (int i=0; i<data.length; i++) {
        crc = (crc >> 8) ^ table[(crc & 0xff) ^ bytes[i]];
    }
    crc ^= 0xffffffff;
    
    free(table);
    return crc;
}

+ (NSString *)sign:(NSString *)priKey data:(NSData *) data {
    int64_t hm = [self dataCRC32:data];
    SSNBriefRSAKey *key = [self separateKey:priKey];
    //s=(h(m))^d mod n;
    SSNBInteger h,n,d;
    ssn_long_to_bigInt(hm, &h);
    ssn_long_to_bigInt(key.n, &n);
    ssn_long_to_bigInt(key.v, &d);
    SSNBInteger c;
    ssn_bigint_pow_mod(&h, &d, &n, &c);
    char bytes[64];
    int len = ssn_bigint_transform_in_bytes(&c, bytes, 64);
    NSData *sign = [NSData dataWithBytes:bytes length:len];
    return [sign base64EncodedStringWithOptions:0];
}


+ (BOOL)verify:(NSString *)pubKey sign:(NSString *)sign data:(NSData *)data {
    int64_t hm = [self dataCRC32:data];
    
    SSNBriefRSAKey *key = [self separateKey:pubKey];
    SSNBInteger s;
    
    NSData *ss = [[NSData alloc] initWithBase64EncodedString:sign options:0];
    ssn_bigint_transform_from_bytes([ss bytes], &s, (unsigned int)([ss length]));
    
    SSNBInteger n,e,HM;
    ssn_long_to_bigInt(key.n, &n);
    ssn_long_to_bigInt(key.v, &e);
    // H(m) = s^e mod n;
    ssn_bigint_pow_mod(&s, &e, &n, &HM);
    return ssn_bigint_to_long(&HM) == hm;
}

@end
