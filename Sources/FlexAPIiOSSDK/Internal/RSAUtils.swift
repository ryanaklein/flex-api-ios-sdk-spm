import Foundation
import Security

class RSAUtils {
    
    static func readKeys(fromFile keyName: String) -> String? {
        let bundle = Bundle.module
        guard let path = bundle.path(forResource: keyName, ofType: "txt"),
              let publicKeyString = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }
        return publicKeyString
    }
    
    static func rsaPublicKeyRef(fromBase64String key: String, withTag tag: String) -> SecKey? {
        var keyString = ""
        let lines = key.components(separatedBy: "\n")
        var inKey = false
        
        for line in lines {
            if line == "-----BEGIN PUBLIC KEY-----" {
                inKey = true
            } else if line == "-----END PUBLIC KEY-----" {
                inKey = false
            } else if inKey {
                keyString += line
            }
        }
        
        if keyString.isEmpty {
            return nil
        }
        
        guard let keyData = Data(base64Encoded: keyString) else {
            return nil
        }
        
        guard let strippedKeyData = stripPublicKeyHeader(keyData) else {
            return nil
        }
        
        let tagData = tag.data(using: .utf8)!
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag as String: tagData,
            kSecAttrKeySizeInBits as String: strippedKeyData.count * 8
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(strippedKeyData as CFData,
                                                attributes as CFDictionary,
                                                &error) else {
            if let error = error {
                print("Error creating SecKey: \(error.takeRetainedValue())")
            }
            return nil
        }
        
        return secKey
    }
    
    private static func stripPublicKeyHeader(_ keyData: Data) -> Data? {
        guard !keyData.isEmpty else { return nil }
        
        let bytes = [UInt8](keyData)
        var index = 0
        
        guard bytes[index] == 0x30 else { return nil }
        index += 1
        
        if bytes[index] > 0x80 {
            index += Int(bytes[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        let seqOID: [UInt8] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                               0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
        
        guard index + seqOID.count <= bytes.count else { return nil }
        
        let slice = Array(bytes[index..<(index + seqOID.count)])
        guard slice == seqOID else { return nil }
        
        index += seqOID.count
        
        guard bytes[index] == 0x03 else { return nil }
        index += 1
        
        if bytes[index] > 0x80 {
            index += Int(bytes[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        guard bytes[index] == 0x00 else { return nil }
        index += 1
        
        return Data(bytes[index...])
    }
}