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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !SSHKeychain.message.isEmpty {
            infoTextField.stringValue = SSHKeychain.message
        }
        
        if SSHKeychain.isConfirmation {
            passwordTextField.isHidden = true
            if let controlView = keychainCheckBox.controlView {
                controlView.isHidden = true
            }
        } else if SSHKeychain.keypath.isEmpty {
            keychainCheckBox.state = NSControl.StateValue.off
            keychainCheckBox.isEnabled = false
        }
    }

    @IBAction func cancel(_ sender: Any) {
        exit(1)
    }
    
    @IBAction func ok(_ sender: Any) {
        if !SSHKeychain.keypath.isEmpty && keychainCheckBox.state == NSControl.StateValue.on {
            let status = SSHKeychain.add(keypath: SSHKeychain.keypath, password: passwordTextField.stringValue)
            if status != errSecSuccess {
                let alert = NSAlert()
                alert.messageText = "Keychain Error"
                alert.informativeText = SecCopyErrorMessageString(status, nil)! as String
                alert.icon = NSImage(named: NSImage.cautionName)
                alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                return
            }
        }
        print(passwordTextField.stringValue)
        exit(0)
    }
}
