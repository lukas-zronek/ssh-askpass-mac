//
//  main.swift
//  ssh-askpass
//
//  Created by Lukas on 22.09.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Cocoa

SSHKeychain.setup(message: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "")

if !SSHKeychain.shared.keypath.isEmpty, let password = SSHKeychain.shared.get() {
    print(password)
    exit(0)
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
