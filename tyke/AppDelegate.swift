//
//  AppDelegate.swift
//  tyke
//
//  Created by Andre Torrez on 8/17/17.
//  Copyright © 2017 Andre Torrez. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //var statusItem: NSStatusItem?

    let popover = NSPopover()
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        popover.behavior = NSPopoverBehavior.transient
        popover.animates = false
        //self.statusItem = NSStatusBar.system().statusItem(withLength:-1)

        if let button = statusItem.button {
            button.image = NSImage(named: "dabutton")
            button.image?.size = NSSize(width: 20, height: 18)
            button.image?.isTemplate = true
            button.action =  #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = EditorViewController(nibName: "EditorViewController", bundle: nil)
        
//        self.statusItem = NSStatusBar.system().statusItem(withLength:-1)
//        
//        // Set the text that appears in the menu bar
//        self.statusItem!.title = "Star!"
//        self.statusItem?.image = NSImage(named: "Star")
//        self.statusItem?.image?.size = NSSize(width: 20, height: 18)
//        self.statusItem?.length = 70
//        // image should be set as tempate so that it changes when the user sets the menu bar to a dark theme
//        self.statusItem?.image?.isTemplate = true
//        
//        // Set the menu that should appear when the item is clicked
//        //self.statusItem!.menu = self.menu
//        self.statusItem!.menu = self.editor
//
//        
//        // Set if the item should change color when clicked
//        self.statusItem!.highlightMode = true
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            NSApplication.shared().activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender:sender)
        } else {
            showPopover(sender:sender)
        }
    }
}

