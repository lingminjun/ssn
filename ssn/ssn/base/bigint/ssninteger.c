//
//  ssninteger.c
//  ssn
//
//  Created by fengqu on 2017/5/20.
//  Copyright © 2017年 lingminjun. All rights reserved.
//

#include "ssninteger.h"

typedef struct    // Number均用真值表示
{
    char value[BIG_INT_BIT_LEN];  // 数字数组 存放按照进制每位上的实际值 最高位在最下面
    int len;                      // 数组长度
    int sign;                     // 符号标记
} SSNBNumber;


// 打印SSNBInteger
void ssn_bigint_print(const SSNBInteger* const a)
{
    int i;
    for (i = SIGN_BIT; i >= 0; i--) {
        printf("%d", a->bit[i]);
    }
    printf("\n");
}

// 打印Number
void ssn_bigint_number_print(const SSNBNumber* const n)
{
    int i;
    
    if (n->sign == NEGATIVE) {
        printf("-");
    }
    
    for (i = n->len - 1; i >= 0; i--)
    {
        if (n->value[i] > 9)  // 大于10进制的情况
        {
            printf("%c", n->value[i] - 10 + 'a');
        }
        else
        {
            printf("%d", n->value[i]);
        }
    }
    printf("\n");
}

// 把str转为Number数字类型, 返回Number*
SSNBNumber* const ssn_bigint_str_to_number(const char* str, SSNBNumber*const n)
{
    int i, j;
    
    if (str[0] == '-' || str[0] == '+')  // 0号单元存放符号
    {
        n->len = (int)(strlen(str) - 1);
        n->sign = str[0] == '+' ? POSITIVE : NEGATIVE;
        
        for (i = 0, j = n->len; j > 0; j--, i++)
        {
            if (str[j] > '9')  // 大于10进制的情况
            {
                n->value[i] = str[j] - 'a' + 10;
            }
            else
            {
                n->value[i] = str[j] - '0';
            }
        }
    }
    else
    {
        n->len = (int)(strlen(str));
        n->sign = POSITIVE;
        
        for (i = 0, j = n->len - 1; j >= 0; j--, i++)
        {
            if (str[j] > '9')  // 大于10进制的情况
            {
                n->value[i] = str[j] - 'a' + 10;
            }
            else
            {
                n->value[i] = str[j] - '0';
            }
        }
    }
    
    return n;
}

//void ssn_long_to_binary_in_number(const long n, SSNBNumber*const nb)
//{
//    int r;
//    r = n % 2;
//    if(n >= 2) {
//        ssn_long_to_binary_in_number(n / 2, nb);
//    }
//    nb->value[nb->len] = r;
//    n->len += 1;
//    return;
//}

// 把long转为Number数字类型, 返回Number*
SSNBNumber* const ssn_bigint_long_to_number(const int64_t lv, SSNBNumber*const n)
{
    n->sign = lv >= 0 ? POSITIVE : NEGATIVE;
    long ll = lv;
    if (lv < 0) {
        ll = -lv;
    }
    
    //太耗费内存，修改为while //unsiged long long 1844674407370955161
//    char value[65];
//    int i = 0;
    n->len = 0;
    while (ll > 0) {
        n->value[n->len] = ll % 2;
        ll = ll / 2;
        n->len += 1;
    }
    
//    n->len = i;//计算数据的长度
    
//    while (i > 0) {
//        i--;//反向
//        n->value[i] = value[n->len - i];
//    }
    
    //ssn_long_to_binary_in_number(n, nb);
    return n;
}


// Number类型转字符串类型
const char* ssn_bigint_number_to_str(const SSNBNumber* n, char* str)
{
    int i = 0, j;
    
    if (n->sign == NEGATIVE) {
        str[i++] = '-';
    }
    
    for (j = n->len - 1; j >= 0; j--)
    {
        if (n->value[j] > 9)  // 大于10进制的情况
        {
            str[i++] = n->value[j] - 10 + 'a';
        }
        else {
            str[i++] = n->value[j] + '0';
        }
    }
    
    str[i] = '\0';
    
    return str;
}

// 2进制字符串转16进制字符串
const char* ssn_str_bin_to_hex(const char* binStr, char* hexStr)
{
    int i, j, t;
    SSNBNumber binNum;
    SSNBNumber hexNum;
    
    ssn_bigint_str_to_number(binStr, &binNum);
    
    hexNum.sign = binNum.sign;
    hexNum.len = (int)ceil(binNum.len / 4.0);
    
    for (i = 0; i < hexNum.len; i++)
    {
        j = 4 * i;
        
        t = binNum.value[j];
        
        if (j + 1 < binNum.len)
            t += 2 * binNum.value[j + 1];
        
        if (j + 2 < binNum.len)
            t += 4 * binNum.value[j + 2];
        
        if (j + 3 < binNum.len)
            t += 8 * binNum.value[j + 3];
        
        hexNum.value[i] = t;
    }
    
    return ssn_bigint_number_to_str(&hexNum, hexStr);
}

// 字符串进制转换
const char* ssn_str_change_radix(const char* str, int srcBase, int dstBase, char* resultStr)
{
    if (srcBase < dstBase)
    {
        char hexStr[BUFFER_SIZE];
        
        ssn_str_change_radix(str, srcBase, 2, resultStr);
        ssn_str_bin_to_hex(resultStr, hexStr);
        
        return ssn_str_change_radix(hexStr, 16, dstBase, resultStr);
    }
    
    if (srcBase == dstBase)
    {
        return strcpy(resultStr,str);
    }
    else
    {
        int i, t;
        SSNBNumber dividend;   // 被除数
        SSNBNumber quotient;   // 商
        SSNBNumber resultNum;  // 结果
        
        // 把str转换为Number数字类型
        ssn_bigint_str_to_number(str, &dividend);
        
        resultNum.len = 0;
        resultNum.sign = dividend.sign;
        
        while (dividend.len > 0)
        {
            quotient.len = dividend.len;
            
            // 模拟人做除法的方式, 即一轮(求一位余数)的过程
            for (t = 0, i = dividend.len - 1; i >= 0; i--)
            {
                t = t * srcBase + dividend.value[i];
                quotient.value[i] = t / dstBase;
                t = t % dstBase;      // 循环最后的t即为一轮的结果
            }
            
            // 保存一轮的结果, 即一位余数
            resultNum.value[resultNum.len++] = t;
            
            // 过滤商中多余的0
            for (i = quotient.len - 1; i >= 0 && quotient.value[i] == 0; i--);
            
            dividend.len = i + 1;
            
            // 把商作为下一轮的被除数
            for (i = 0; i < dividend.len; i++)
            {
                dividend.value[i] = quotient.value[i];
            }
        }
        
        return ssn_bigint_number_to_str(&resultNum, resultStr);
    }
}

// 原码<=>补码
SSNBInteger* const ssn_bigint_complement(const SSNBInteger* const src, SSNBInteger* const dst)
{
    int i;
    
    if (src->bit[SIGN_BIT] == NEGATIVE)  // 负数求补
    {
        dst->bit[SIGN_BIT] = 1;
        
        for (i = 0; i < SIGN_BIT && src->bit[i] == 0; i++)
        {
            dst->bit[i] = src->bit[i];
        }
        
        if (i == SIGN_BIT)    // -0的补码
        {
            dst->bit[i] = 0;
        }
        else                  // 非0补码
        {
            dst->bit[i] = src->bit[i];
            for (i++; i < SIGN_BIT; i++)
            {
                dst->bit[i] = !src->bit[i];
            }
        }
    }
    else  // 正数求补不变
    {
        for (i = 0; i < BIG_INT_BIT_LEN; i++)
        {
            dst->bit[i] = src->bit[i];
        }
    }
    
    return dst;
}

// 转为原码
SSNBInteger* const ssn_bigint_complemet_copy(const SSNBInteger* const src, SSNBInteger* const dst)
{
    return ssn_bigint_complement(src, dst);
}

// 转为相反数的补码 [x]补 => [-x]补,
// 注意：例如如果是8位整数，不能求-128相反数的补码
// 算法的思想是连同符号位一起求补，即符号位也要取反，可证明是正确的
SSNBInteger* const ssn_bigint_not(const SSNBInteger* const src, SSNBInteger* const dst)
{
    int i;
    
    for (i = 0; i < BIG_INT_BIT_LEN && src->bit[i] == 0; i++)
        dst->bit[i] = src->bit[i];
    
    // 求非0相反数的补码
    if (i != BIG_INT_BIT_LEN)
    {
        dst->bit[i] = src->bit[i];
        
        // 即符号位也要取反
        for (i++; i < BIG_INT_BIT_LEN; i++)
            dst->bit[i] = !src->bit[i];
    }
    
    return dst;
}

/* 基本实现
 // 转为相反数的补码 [x]补 => [-x]补
 SSNBInteger* ToOppositeNumberComplement(SSNBInteger* src, SSNBInteger* dst)
 {
 SSNBInteger t;
 ToTrueForm(src, &t);
 t.bit[SIGN_BIT] = !t.bit[SIGN_BIT];
 ToComplement(&t, dst);
 return dst;
 }
 */

// 2进制Number转SSNBInteger
SSNBInteger* ssn_binnumber_to_bigInt(const SSNBNumber* binNum, SSNBInteger* a)
{
    int i;
    
    memset(a->bit, 0, BIG_INT_BIT_LEN);  // 初始化为0
    
    for (i = 0; i < binNum->len; i++)
    {
        a->bit[i] = binNum->value[i];
    }
    
    // 负数取下界的情况：如4位整型[1000]
    if (binNum->len == BIG_INT_BIT_LEN)
    {
        return a;
    }
    else
    {
        a->bit[SIGN_BIT] = binNum->sign;  // 符号位
        return ssn_bigint_complement(a, a);
    }
}

// SSNBInteger转2进制Number
SSNBNumber* const ssn_bigInt_to_binnumber(const SSNBInteger* const a, SSNBNumber* const binNum)
{
    int i;
    SSNBInteger t;
    
    binNum->sign = a->bit[SIGN_BIT];
    
    for (i = SIGN_BIT - 1; i >= 0 && a->bit[i] == 0; i--);
    
    // SSNBInteger为负数的下界时
    if (binNum->sign == NEGATIVE && i == -1)
    {
        binNum->len = BIG_INT_BIT_LEN;
        for (i = 0; i < binNum->len; i++)
        {
            binNum->value[i] = a->bit[i];
        }
    }
    else
    {
        ssn_bigint_complemet_copy(a, &t);
        for (i = SIGN_BIT - 1; i >= 0 && t.bit[i] == 0; i--);
        binNum->len = i == -1 ? 1 : i + 1;
        for (i = 0; i < binNum->len; i++)
        {
            binNum->value[i] = t.bit[i];
        }
    }
    
    return binNum;
}

// 字符串转SSNBInteger，以补码存储
SSNBInteger* const ssn_str_to_bigInt(const char* s, SSNBInteger* const a)
{
    char buf[BUFFER_SIZE];
    SSNBNumber binNum;
    
    ssn_str_change_radix(s, 10, 2, buf);              // 十进制转二进制
    ssn_bigint_str_to_number(buf, &binNum);           // string转Number
    return ssn_binnumber_to_bigInt(&binNum, a);   // Number转SSNBInteger
}

// int64_t转SSNBInteger，以补码存储
SSN_BIG_INT_EXTERN SSNBInteger* const ssn_long_to_bigInt(const int64_t i, SSNBInteger* const a) {
    SSNBNumber binNum;
    ssn_bigint_long_to_number(i, &binNum);           // string转Number
    return ssn_binnumber_to_bigInt(&binNum, a);   // Number转SSNBInteger
}

// SSNBInteger转字符串，以10进制表示
const char* ssn_bigint_to_str(SSNBInteger* a, char* s)
{
    char buf[BUFFER_SIZE];
    SSNBNumber binNum;
    
    ssn_bigInt_to_binnumber(a, &binNum);     // SSNBInteger转Number
    ssn_bigint_number_to_str(&binNum, buf);      // Number转string
    
    return ssn_str_change_radix(buf, 2, 10, s);  // 二进制转十进制
}

// SSNBInteger转字符串
SSN_BIG_INT_EXTERN const int64_t ssn_bigint_to_long(const SSNBInteger* const a) {
    char buf[BUFFER_SIZE];
    SSNBNumber binNum;
//    memset(binNum.value, 0, BUFFER_SIZE);
    
    ssn_bigInt_to_binnumber(a, &binNum);     // SSNBInteger转Number
    ssn_bigint_number_to_str(&binNum, buf);      // Number转string,此时存在问题，不知道目标是否为2进制？？
    
    return strtoll(buf, NULL, 2);
}

SSN_BIG_INT_EXTERN int ssn_bigint_transform_in_bytes(const SSNBInteger* const a, void *bytes, const int len) {
    memset(bytes, 0x00, len);
    
    int64_t value = ssn_bigint_to_long(a);
    int lenx = ssn_bigint_value_len(a);
    int size = (lenx + 7) / 8;
    
    char *bts = (char *)bytes;
    if (lenx % 8 == 0) {//保留符号位
        size += 1;
    }
    for (int i = 0; i < size && i < len; i++) {
        bts[size - i - 1] = (value >> (i * 8));
    }
    return size;
}

//从byte中转换
SSN_BIG_INT_EXTERN void ssn_bigint_transform_from_bytes(const void *const bytes, SSNBInteger* const a, const unsigned int len) {
    if (len * 8 >= BUFFER_SIZE) {
        abort();
    }
    
    if (len > sizeof(int64_t)) {//暂时不支持大于int64的数
        abort();
    }
    
    memset(a->bit, 0x00, BIG_INT_BIT_LEN);
    
    char bts[BUFFER_SIZE];
    memset(bts, 0x00, BUFFER_SIZE);
    memcpy(bts, bytes, len);
    int byte_len = len * 8;
    if (bts[0] < 0) {//负数
        memset(a->bit, 0x01, BIG_INT_BIT_LEN);
        int loc = 7;
        do {
            int vv = (bts[0] >> loc) & 0x01;//从最高位开始校正
            if (vv == 0) {
                break;
            }
            
            bts[0] = (~(0x01 << loc)) & bts[0];
            
            loc--;
            byte_len--;
        } while (loc >= 0);
    }
    
    //反向复制给biginter
    for (int i = 0; i < len; i++) {
        for (int j = 0; j < 8 && ((i * 8) + j) < byte_len; j++) {//按字节赋值
            int value = (bts[len - i - 1] >> j) & 0x01;
            a->bit[(i*8)+j] = value;
        }
    }
//    ssn_bigint_print(a);
}

// 复制SSNBInteger
SSNBInteger* const ssn_bigint_copy(const SSNBInteger* const src, SSNBInteger* const dst)
{
    int i;
    for (i = 0; i < BIG_INT_BIT_LEN; i++)
        dst->bit[i] = src->bit[i];
    return dst;
}

// 算术左移
SSNBInteger* const ssn_bigint_bit_left_move(const SSNBInteger* const src, const int indent, SSNBInteger* const dst)
{
    int i, j;
    
    dst->bit[SIGN_BIT] = src->bit[SIGN_BIT];
    
    for (i = SIGN_BIT - 1, j = i - indent; j >= 0; i--, j--)
    {
        dst->bit[i] = src->bit[j];
    }
    
    while (i >= 0)
    {
        dst->bit[i--] = 0;
    }
    
    return dst;
}

// 加法实现
SSNBInteger* const ssn_bigint_add(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result)
{
    int i, t, carryFlag;           // 进位标志
    int aSign = a->bit[SIGN_BIT];  // a的符号
    int bSign = b->bit[SIGN_BIT];  // b的符号
    
    for (carryFlag = i = 0; i < BIG_INT_BIT_LEN; i++)
    {
        t = a->bit[i] + b->bit[i] + carryFlag;
        result->bit[i] = t % 2;
        carryFlag = t > 1 ? 1 : 0;
    }
    
    if (aSign == bSign && aSign != result->bit[SIGN_BIT])
    {
        printf("Overflow XD\n");
        exit(1);
    }
    
    return result;
}

// 减法实现
SSNBInteger* const ssn_bigint_sub(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result)
{
    SSNBInteger t;
    
    ssn_bigint_not(b, &t);
    ssn_bigint_add(a, &t, result);
    
    return result;
}

// 乘法实现 Booth算法[补码1位乘] 转化为移位和加法
SSNBInteger* const ssn_bigint_mul(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result)
{
    int i;
    SSNBInteger c, t;
    
    ssn_bigint_not(a, &c);  // c=[-a]的补
    
    memset(t.bit, 0, BIG_INT_BIT_LEN);  // 初始化为0
    
    // 从高位处开始，过滤相同的位，因为相减为0
    for (i = SIGN_BIT; i > 0 && b->bit[i] == b->bit[i - 1]; i--);
    
    while (i > 0)
    {
        ssn_bigint_bit_left_move(&t, 1, &t);
        
        if (b->bit[i] != b->bit[i - 1])
        {
            ssn_bigint_add(&t, b->bit[i - 1] > b->bit[i] ? a : &c, &t);
        }
        
        i--;
    }
    
    // 最后一步的移位
    ssn_bigint_bit_left_move(&t, 1, &t);
    if (b->bit[0] != 0)
    {
        ssn_bigint_add(&t, &c, &t);
    }
    
    return ssn_bigint_copy(&t, result);
}

// 在不溢出的情况下，获取最大算术左移的长度
int ssn_bigint_empty_left_byte_len(const SSNBInteger* const a)
{
    int i, k;
    SSNBInteger t;
    
    ssn_bigint_complemet_copy(a, &t);
    
    for (i = SIGN_BIT - 1, k = 0; i >= 0 && t.bit[i] == 0; i--, k++);
    
    return k;
}

// 判断Bigint是否为0
int ssn_is_zero(const SSNBInteger* const a)
{
    int i;
    for (i = 0; i < BIG_INT_BIT_LEN; i++)
    {
        if (a->bit[i] != 0)
            return 0;
    }
    return 1;
}

// 除法实现 用2分法去求商的各个为1的位 写得不够简洁><
SSNBInteger* const ssn_bigint_div(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result, SSNBInteger* const remainder)
{
    int low, high, mid;
    SSNBInteger c, d, e, t;
    
    low = 0;                       // 初始化左移下限值
    high = ssn_bigint_empty_left_byte_len(b);  // 获取最大算术左移的长度
    
    memset(t.bit, 0, BIG_INT_BIT_LEN);  // 初始化商为0
    ssn_bigint_copy(a, &c);                  // 初始化c为被除数a
    
    // 同号情况作减
    if (a->bit[SIGN_BIT] == b->bit[SIGN_BIT])
    {
        t.bit[SIGN_BIT] = POSITIVE;
        
        while (1)
        {
            while (low <= high)
            {
                mid = (low + high) / 2;
                ssn_bigint_bit_left_move(b, mid, &d);
                ssn_bigint_sub(&c, &d, &e);  // e = c - d
                
                // e >= 0，表示够减
                if (d.bit[SIGN_BIT] == e.bit[SIGN_BIT] || ssn_is_zero(&e))
                    low = mid + 1;
                else
                    high = mid - 1;
            }
            
            // high是最后够减的移位数
            // high == -1 表示已经连1倍的除数都不够减了
            if (high != -1)
            {
                t.bit[high] = 1;
                
                // 这里统一操作了，可改进
                ssn_bigint_bit_left_move(b, high, &d);
                ssn_bigint_sub(&c, &d, &c);  // c = c - d
                
                low = 0;
                high--;
            }
            else
            {
                // 这时c所表示的被除数即为最后的余数
                ssn_bigint_copy(&c, remainder);
                break;
            }
        }
    }
    
    // 异号情况作加
    else
    {
        t.bit[SIGN_BIT] = NEGATIVE;
        
        while (1)
        {
            while (low <= high)
            {
                mid = (low + high) / 2;
                ssn_bigint_bit_left_move(b, mid, &d);
                ssn_bigint_add(&c, &d, &e);  // e = c + d
                
                // e >= 0
                if (d.bit[SIGN_BIT] != e.bit[SIGN_BIT] || ssn_is_zero(&e))
                    low = mid + 1;
                else
                    high = mid - 1;
            }
            
            // high是最后够减的移位数
            // high == -1 表示已经连1倍的除数都不够减了
            if (high != -1)
            {
                t.bit[high] = 1;
                
                // 这里统一操作了，可改进
                ssn_bigint_bit_left_move(b, high, &d);
                ssn_bigint_add(&c, &d, &c);  // c = c + d
                
                low = 0;
                high--;
            }
            else
            {
                // 这时c所表示的被除数即为最后的余数
                ssn_bigint_copy(&c, remainder);
                break;
            }
        }
    }
    
    return ssn_bigint_complement(&t, result);
}

const char* ssn_str_add(const char* s1, const char* s2, char* result)
{
    SSNBInteger a, b, c;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_bigint_add(&a, &b, &c);
    
    return ssn_bigint_to_str(&c, result);
}

const char* ssn_str_sub(const char* s1, const char* s2, char* result)
{
    SSNBInteger a, b, c;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_bigint_sub(&a, &b, &c);
    
    return ssn_bigint_to_str(&c, result);
}

const char* ssn_str_mul(const char* s1, const char* s2, char* result)
{
    SSNBInteger a, b, c;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_bigint_mul(&a, &b, &c);
    
    return ssn_bigint_to_str(&c, result);
}

const char* ssn_str_div(const char* s1, const char* s2, char* result, char* remainder)
{
    SSNBInteger a, b, c, d;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_bigint_div(&a, &b, &c, &d);
    ssn_bigint_to_str(&d, remainder);
    
    return ssn_bigint_to_str(&c, result);
}

// 求模实现
SSNBInteger* const ssn_bigint_mod(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const remainder)
{
    SSNBInteger c;
    
    ssn_bigint_div(a, b, &c, remainder);
    
    return remainder;
}

const char* ssn_str_mod(const char* s1, const char* s2, char* remainder)
{
    SSNBInteger a, b, c;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_bigint_mod(&a, &b, &c);
    
    return ssn_bigint_to_str(&c, remainder);
}

// 获取SSNBInteger真值的位长度
int ssn_bigint_value_len(const SSNBInteger* const a)
{
    int i;
    SSNBInteger t;
    
    ssn_bigint_complemet_copy(a, &t);
    
    for (i = SIGN_BIT - 1; i >= 0 && t.bit[i] == 0; i--);
    
    return i + 1;
}

// 幂运算(二进制实现) 不能求负幂
SSNBInteger* const ssn_bigint_pow(const SSNBInteger* const a, const SSNBInteger* const b, SSNBInteger* const result)
{
    int i, len;
    SSNBInteger t, buf;
    
    ssn_bigint_copy(a, &buf);
    ssn_str_to_bigInt("1", &t);
    len = ssn_bigint_value_len(b);  // 获取SSNBInteger真值的位长度
    
    for (i = 0; i < len; i++)
    {
        if (b->bit[i] == 1)
            ssn_bigint_mul(&t, &buf, &t);  // t = t * buf
        
        // 这里最后多做了一次
        ssn_bigint_mul(&buf, &buf, &buf);  // buf = buf * buf
    }
    
    return ssn_bigint_copy(&t, result);
}

const char* ssn_str_pow(const char* s1, const char* s2, char* result)
{
    SSNBInteger a, b, c;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_bigint_pow(&a, &b, &c);
    
    return ssn_bigint_to_str(&c, result);
}

// 模幂运算(二进制实现)
SSNBInteger* const ssn_bigint_pow_mod(const SSNBInteger* const a, const SSNBInteger* const b, const SSNBInteger* const c, SSNBInteger* const result)
{
    int i, len;
    SSNBInteger t, buf;
    
    ssn_bigint_copy(a, &buf);
    ssn_str_to_bigInt("1", &t);
    len = ssn_bigint_value_len(b);  // 获取SSNBInteger真值的位长度
    
    for (i = 0; i < len; i++)
    {
        if (b->bit[i] == 1)
        {
            ssn_bigint_mul(&t, &buf, &t);  // t = t * buf
            ssn_bigint_mod(&t, c, &t);     // t = t % c;
        }
        
        // 这里最后多做了一次
        ssn_bigint_mul(&buf, &buf, &buf);  // buf = buf * buf
        ssn_bigint_mod(&buf, c, &buf);     // buf = buf % c
    }
    
    return ssn_bigint_copy(&t, result);
}

const char* ssn_str_pow_mod(const char* s1, const char* s2, const char* s3, char* result)
{
    SSNBInteger a, b, c, d;
    
    ssn_str_to_bigInt(s1, &a);
    ssn_str_to_bigInt(s2, &b);
    ssn_str_to_bigInt(s3, &c);
    ssn_bigint_pow_mod(&a, &b, &c, &d);
    
    return ssn_bigint_to_str(&d, result);
}
