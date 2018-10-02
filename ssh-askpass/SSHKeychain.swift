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
    
    enum PatternType {
        case prompt
        case failedAttempt
        case confirmation
    }
    
    static let patterns: DictionaryLiteral = [
        "^Enter passphrase for (.*?)( \\(will confirm each use\\))?: $": PatternType.prompt,
        "^Bad passphrase, try again for (.*?)( \\(will confirm each use\\))?: $": PatternType.failedAttempt,
        "^Allow use of key (.*)\\?": PatternType.confirmation,
        "^Add key (.*) \\(.*\\) to agent\\?$": PatternType.confirmation
    ]
    
    var message = String()
    var keypath = String()
    var isConfirmation = false
    var failedAttempt = false
    
    private init() {}
    
    class func setup(message: String) {
        shared.message = message
        
        for (pattern, type) in patterns {
            if let keypath = message.parseKeyPath(pattern: pattern) {
                switch type {
                case PatternType.prompt:
                    shared.keypath = keypath
                case PatternType.failedAttempt:
                    shared.keypath = keypath
                    shared.failedAttempt = true
                case PatternType.confirmation:
                    shared.isConfirmation = true
                }
                break
            }
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

        let label = "\(DefaultValues.LabelPrefix)\(keypath)"
        
        // no apps are trusted to access the keychain item
        var accessRef: SecAccess?
        status = SecAccessCreate(label as CFString, [] as CFArray, &accessRef)
        if status != errSecSuccess {
            return status
        }
        
        let query: [CFString: Any] = [
            kSecClass: DefaultValues.itemClass,
            kSecAttrLabel: label,
            kSecAttrDescription: DefaultValues.Description,
            kSecAttrService: DefaultValues.Service,
            kSecAttrAccessible: DefaultValues.Accessible,
            kSecAttrAccess: accessRef!,
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
