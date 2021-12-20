//
// SSHAskpass.swift
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

import Foundation

class SSHAskpass {

    static let shared = SSHAskpass()

    enum PatternType {
        case prompt
        case failedAttempt
        case confirmation
    }

    let patterns: KeyValuePairs = [
        "^Enter passphrase for (.*?)( \\(will confirm each use\\))?: $": PatternType.prompt,
        "^Bad passphrase, try again for (.*?)( \\(will confirm each use\\))?: $": PatternType.failedAttempt,
        "^Allow use of key (.*)\\?": PatternType.confirmation,
        "^Add key (.*) \\(.*\\) to agent\\?$": PatternType.confirmation
    ]

    var message = String()
    var keypath = String()
    var isConfirmation = false
    var failedAttempt = false

    func setup(message: String) {
        self.message = message

        for (pattern, type) in patterns {
            if let keypath = message.parseKeyPath(pattern: pattern) {
                if keypath == "(stdin)" {
                    break
                }

                switch type {
                case PatternType.prompt:
                    self.keypath = keypath
                case PatternType.failedAttempt:
                    self.keypath = keypath
                    self.failedAttempt = true
                case PatternType.confirmation:
                    self.isConfirmation = true
                }
                break
            }
        }
    }
}
