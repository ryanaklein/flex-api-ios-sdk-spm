//
//  AESGCM.swift
//  flex_api_ios_sdk
//
//  Created by Rakesh Ramamurthy on 21/04/21.
//

import Foundation
import CryptoKit

func aesGcmEncrypt(plaintext: Data, key: Data, iv: Data, tagLen: Int, aad: Data) throws -> (ciphertext: Data, tag: Data) {
    guard key.count == 32 || key.count == 16 || key.count == 24 else {
        throw Tools.createErrorObjectFrom(status: 4000, reason: "Invalid key size", message: "AES key must be 128, 192, or 256 bits")
    }
    
    do {
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: iv)
        
        let sealedBox = try AES.GCM.seal(plaintext, using: symmetricKey, nonce: nonce, authenticating: aad)
        
        let ciphertext = sealedBox.ciphertext
        let tag = sealedBox.tag
        
        return (ciphertext, tag)
    } catch {
        throw Tools.createErrorObjectFrom(status: 4000, reason: "Encryption error", message: "Failed to encrypt data: \(error.localizedDescription)")
    }
}
