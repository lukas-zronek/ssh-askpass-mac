//
//  ViewController.swift
//  ssh-askpass
//
//  Created by Lukas on 14.06.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var infoTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var keychainCheckBox: NSButtonCell!
    
    let sshKeychain = SSHKeychain.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !sshKeychain.message.isEmpty {
            infoTextField.stringValue = sshKeychain.message
        }
        
        if sshKeychain.isConfirmation {
            passwordTextField.isHidden = true
            if let controlView = keychainCheckBox.controlView {
                controlView.isHidden = true
            }
        } else if sshKeychain.keypath.isEmpty {
            keychainCheckBox.state = NSControl.StateValue.off
            keychainCheckBox.isEnabled = false
        }
    }

    @IBAction func cancel(_ sender: Any) {
        exit(1)
    }
    
    @IBAction func ok(_ sender: Any) {
        if !sshKeychain.keypath.isEmpty && keychainCheckBox.state == NSControl.StateValue.on {
            let status = sshKeychain.add(password: passwordTextField.stringValue)

            if status == errSecDuplicateItem {
                ask(messageText: "Warning", informativeText: "A passphrase for \"\(sshKeychain.keypath)\" already exists in the keychain.\nDo you want to replace it?", okButtonTitle: "Replace", completionHandler: { (result) in
                    if result == .alertFirstButtonReturn {
                        let status = self.sshKeychain.delete()
                        if status == errSecSuccess {
                            self.ok(self)
                        } else {
                            self.error(messageText: "Keychain Error", informativeText: SecCopyErrorMessageString(status, nil)! as String)
                            return
                        }
                    }
                })
                return
            } else if status != errSecSuccess {
                error(messageText: "Keychain Error", informativeText: SecCopyErrorMessageString(status, nil)! as String)
                return
            }
        }
        print(passwordTextField.stringValue)
        exit(0)
    }
    
    func error(messageText: String, informativeText: String) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        #if swift(>=4.2)
        let cautionName = NSImage.cautionName
        #else
        let cautionName = NSImage.Name.caution
        #endif
        alert.icon = NSImage(named: cautionName)
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    func ask(messageText: String, informativeText: String, okButtonTitle: String, completionHandler: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.informativeText = informativeText
        #if swift(>=4.2)
        let cautionName = NSImage.cautionName
        #else
        let cautionName = NSImage.Name.caution
        #endif
        alert.icon = NSImage(named: cautionName)
        _ = alert.addButton(withTitle: okButtonTitle)
        _ = alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.view.window!, completionHandler: completionHandler)
    }
}
