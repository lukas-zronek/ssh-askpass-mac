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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if CommandLine.arguments.count > 1 {
            infoTextField.stringValue = CommandLine.arguments[1]
        }
    }

    @IBAction func cancel(_ sender: Any) {
        exit(1)
    }
    
    @IBAction func ok(_ sender: Any) {
        print(passwordTextField.stringValue)
        exit(0)
    }
}
