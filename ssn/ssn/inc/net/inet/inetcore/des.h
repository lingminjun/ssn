//	DES function prototypes

#ifndef	__ZUS_DES_H_
#define __ZUS_DES_H_

#include <string>


class DesEncrypt
{
public:
//mode == 0: standard Data Encryption Algorithm
//mode == 1: DEA without initial and final permutations for speed
//mode == 2: DEA without permutations and with 128-byte key (completely
//          independent subkeys for each round)
    DesEncrypt(int mode = 0) : m_mode(mode) { };
    ~DesEncrypt() { }

    void SetMode(int mode)
    {
        m_mode = mode;
    }

    std::string SetKey(const std::string& key);

    std::string Encrypt(const std::string& data);

    std::string Decrypt(const std::string& data);

    void Encrypt(std::string& data, std::string::size_type offset);

    void Decrypt(std::string& data,  std::string::size_type offset);
private:
    int  m_mode;
    std::string m_deskey;
};


#endif	//__DES_H
