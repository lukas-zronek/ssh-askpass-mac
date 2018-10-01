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
            if status != errSecSuccess {
                let alert = NSAlert()
                alert.messageText = "Keychain Error"
                alert.informativeText = SecCopyErrorMessageString(status, nil)! as String
                #if swift(>=4.2)
                let cautionName = NSImage.cautionName
                #else
                let cautionName = NSImage.Name.caution
                #endif
                alert.icon = NSImage(named: cautionName)
                alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                return
            }
        }
        print(passwordTextField.stringValue)
        exit(0)
    }
}
