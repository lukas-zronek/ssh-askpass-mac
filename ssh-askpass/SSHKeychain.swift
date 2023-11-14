//
// SSHKeychain.swift
// This file is part of ssh-askpass-mac
//
// Copyright (c) 2018-2022, Lukas Zronek
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

class SSHKeychain {
    
    static let shared = SSHKeychain()
    
    private init() {}
    
    func get(keypath: String) -> String? {
        var result: AnyObject?
        let query: [CFString: AnyObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keypath as CFString,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == noErr, let data = result as? Data, let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }
    
    func add(keypath: String, password: String) -> OSStatus {
        var status: OSStatus

        let label = "SSH: \(keypath)"
        
        // no apps are trusted to access the keychain item
        var accessRef: SecAccess?
        status = SecAccessCreate(label as CFString, [SecTrustedApplication]() as CFArray, &accessRef)
        if status != errSecSuccess {
            return status
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: label,
            kSecAttrDescription: "OpenSSH passphrase",
            kSecAttrService: "SSH",
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecAttrAccess: accessRef!,
            kSecAttrAccount: keypath,
            kSecValueData: password
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        
        return status
    }
    
    func delete(keypath: String) -> OSStatus {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: keypath
        ]
        return SecItemDelete(query as CFDictionary)
    }
}
