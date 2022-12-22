//
// ViewController.swift
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

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var infoTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var keychainCheckBox: NSButtonCell!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var okButton: NSButton!
    
    let sshKeychain = SSHKeychain.shared
    let sshAskpass = SSHAskpass.shared
    
#if swift(>=4.2)
    let cautionName = NSImage.cautionName
#else
    let cautionName = NSImage.Name.caution
#endif

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !sshAskpass.message.isEmpty {
            infoTextField.stringValue = sshAskpass.message
        }
        switch self.sshAskpass.type {
        case .confirmation:
            passwordTextField.isHidden = true
            if let controlView = keychainCheckBox.controlView {
                controlView.isHidden = true
            }
        case .passphrase:
            if sshAskpass.keypath.isEmpty {
                keychainCheckBox.state = NSControl.StateValue.off
                keychainCheckBox.isEnabled = false
            }
        case .badPassphrase:
            break
        case .inputConfirmation:
            if let controlView = keychainCheckBox.controlView {
                controlView.isHidden = true
            }
        case .information:
            okButton.isHidden = true
            cancelButton.title = "Close"
            passwordTextField.isHidden = true
            if let controlView = keychainCheckBox.controlView {
                controlView.isHidden = true
            }
        }
        
        if let obj = UserDefaults.standard.object(forKey: "useKeychain") {
            if let useKeychain = obj as? Bool {
                if (useKeychain) {
                    keychainCheckBox.state = NSControl.StateValue.on
                } else {
                    keychainCheckBox.state = NSControl.StateValue.off
                }
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        exit(1)
    }
    
    @IBAction func ok(_ sender: Any) {
        if (sshAskpass.type == .passphrase || sshAskpass.type == .badPassphrase) && !sshAskpass.keypath.isEmpty && keychainCheckBox.state == NSControl.StateValue.on {
            let status = sshKeychain.add(keypath: sshAskpass.keypath, password: passwordTextField.stringValue)

            if status == errSecDuplicateItem {
                ask(messageText: "Warning", informativeText: "A passphrase for \"\(sshAskpass.keypath)\" already exists in the keychain.\nDo you want to replace it?", okButtonTitle: "Replace", completionHandler: { (result) in
                    if result == .alertFirstButtonReturn {
                        let status = self.sshKeychain.delete(keypath: self.sshAskpass.keypath)
                        if status == errSecSuccess {
                            self.ok(self)
                        } else {
                            self.keychainError(status: status)
                            return
                        }
                    }
                })
                return
            } else if status != errSecSuccess {
                keychainError(status: status)
                return
            }
        }
        print(passwordTextField.stringValue)
        exit(0)
    }
    
    @IBAction func useKeychainChanged(_ sender: NSButtonCell) {
        var useKeychain:Bool = false
        if (sender.state == NSControl.StateValue.on) {
            useKeychain = true
        }
        UserDefaults.standard.set(useKeychain, forKey: "useKeychain")
    }
    
    func keychainError(status: OSStatus) {
        error(messageText: "Keychain Error", informativeText: SecCopyErrorMessageString(status, nil)! as String)
    }
    
    func error(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.icon = NSImage(named: cautionName)
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func ask(messageText: String, informativeText: String, okButtonTitle: String, completionHandler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        alert.icon = NSImage(named: cautionName)
        _ = alert.addButton(withTitle: okButtonTitle)
        _ = alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.view.window!, completionHandler: completionHandler)
    }
}
