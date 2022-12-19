//
// main.swift
// This file is part of ssh-askpass-mac
//
// Copyright (c) 2021, Lukas Zronek
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

import Cocoa

let promptEnv = ProcessInfo.processInfo.environment["SSH_ASKPASS_PROMPT"];

SSHAskpass.shared.setup(message: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "", promptEnv: promptEnv)

if !SSHAskpass.shared.keypath.isEmpty, SSHAskpass.shared.type == .passphrase {
    let original_keypath = SSHAskpass.shared.keypath
    var isAbsolute = false
    
    if let absolute_keypath = SSHAskpass.shared.keypath.getAbsolutePath() {
        if let password = SSHKeychain.shared.get(keypath: absolute_keypath) {
            print(password)
            exit(0)
        }
        SSHAskpass.shared.keypath = absolute_keypath
        
        if (absolute_keypath == original_keypath) {
            isAbsolute = true
        }
    }
    
    if !isAbsolute {
        if let password = SSHKeychain.shared.get(keypath: original_keypath) {
            print(password)
            exit(0)
        }
    }
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
