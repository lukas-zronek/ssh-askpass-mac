//
//  AppDelegate.swift
//  ssh-askpass
//
//  Created by Lukas on 14.06.18.
//  Copyright © 2018 Lukas Zronek. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let window = NSApp.windows.first {
            window.level = .modalPanel
            window.orderFrontRegardless()
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

