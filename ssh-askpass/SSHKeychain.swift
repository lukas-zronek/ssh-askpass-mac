//
//  SSHKeychain.swift
//  ssh-askpass
//
//  Created by Lukas on 19.09.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Foundation

class SSHKeychain {
    struct DefaultValues {
        static let itemClass = kSecClassGenericPassword
        static let LabelPrefix = "SSH: "
        static let Description = "OpenSSH private key passphrase"
        static let Service = "SSH"
        static let Accessible = kSecAttrAccessibleWhenUnlocked
    }
    static var message = String()
    static var keypath = String()
    
    class func get(keypath: String) -> String? {
        var result: AnyObject?
        var data: Data?
        let query: [CFString: Any] = [
            kSecClass: DefaultValues.itemClass,
            kSecAttrAccount: keypath,
            kSecMatchLimitOne: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == noErr {
            data = result as? Data
        } else {
            return nil
        }
        
        return String(data: data!, encoding: .utf8)!
    }
    
    class func add(keypath: String, password: String) -> OSStatus {
        var status = SSHKeychain.delete(keypath: keypath)
        
        switch status {
        case errSecSuccess, errSecItemNotFound:
                break
        default:
            return status
        }
        
        let query: [CFString: Any] = [
            kSecClass: DefaultValues.itemClass,
            kSecAttrLabel: "\(DefaultValues.LabelPrefix)\(keypath)",
            kSecAttrDescription: DefaultValues.Description,
            kSecAttrService: DefaultValues.Service,
            kSecAttrAccessible: DefaultValues.Accessible,
            kSecAttrAccount: keypath,
            kSecValueData: password
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        
        return status
    }
    
    class func delete(keypath: String) -> OSStatus {
        let query: [CFString: Any] = [
            kSecClass: DefaultValues.itemClass,
            kSecAttrAccount: keypath
        ]
        return SecItemDelete(query as CFDictionary)
    }
}
