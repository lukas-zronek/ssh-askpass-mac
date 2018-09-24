//
//  main.swift
//  ssh-askpass
//
//  Created by Lukas on 22.09.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Cocoa

if CommandLine.arguments.count > 1  {
    SSHKeychain.message = CommandLine.arguments[1]
    
    if let keypath = SSHKeychain.message.parseKeyPath(pattern: "^Enter passphrase for (.*?)( \\(will confirm each use\\))?: $") {
        if let password = SSHKeychain.get(keypath: keypath) {
            print(password)
            exit(0)
        } else {
            SSHKeychain.keypath = keypath
        }
    } else if let keypath = SSHKeychain.message.parseKeyPath(pattern: "^Bad passphrase, try again for (.*?)( \\(will confirm each use\\))?: $") {
        SSHKeychain.keypath = keypath
    } else if SSHKeychain.message.parseKeyPath(pattern: "^Allow use of key (.*?)") != nil {
        SSHKeychain.isConfirmation = true
    }
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
