//
//  SSHKeychain.swift
//  ssh-askpass
//
//  Created by Lukas on 19.09.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Foundation

class SSHKeychain {
    static let shared = SSHKeychain()
    
    struct DefaultValues {
        static let itemClass = kSecClassGenericPassword
        static let LabelPrefix = "SSH: "
        static let Description = "OpenSSH private key passphrase"
        static let Service = "SSH"
        static let Accessible = kSecAttrAccessibleWhenUnlocked
    }
    var message = String()
    var keypath = String()
    var isConfirmation = false
    var failedAttempt = false
    
    private init() {}
    
    class func setup(message: String) {
        shared.message = message
        
        if let keypath = message.parseKeyPath(pattern: "^Enter passphrase for (.*?)( \\(will confirm each use\\))?: $") {
            shared.keypath = keypath
        } else if let keypath = message.parseKeyPath(pattern: "^Bad passphrase, try again for (.*?)( \\(will confirm each use\\))?: $") {
            shared.keypath = keypath
            shared.failedAttempt = true
        } else if message.parseKeyPath(pattern: "^Allow use of key (.*?)") != nil || message.parseKeyPath(pattern: "^Add key (.*) \\(.*\\) to agent\\?$") != nil {
            shared.isConfirmation = true
        }
    }
    
    func get() -> String? {
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
    
    func add(password: String) -> OSStatus {
        var status = delete()
        
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
    
    func delete() -> OSStatus {
        let query: [CFString: Any] = [
            kSecClass: DefaultValues.itemClass,
            kSecAttrAccount: keypath
        ]
        return SecItemDelete(query as CFDictionary)
    }
}
