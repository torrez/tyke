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

    let popover = NSPopover()
    let statusItem = NSStatusBar.system().statusItem(withLength: -2)
    var evc: EditorViewController!
    var smart_quote_menu_item: NSMenuItem!
    var hotKey: HotKey!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        popover.behavior = NSPopoverBehavior.transient
        popover.animates = false
        
        if let button = statusItem.button {
            button.image = NSImage(named: "dabutton")
            button.image?.size = NSSize(width: 20, height: 18)
            button.image?.isTemplate = true
            //button.action =  #selector(AppDelegate.togglePopover(_:))
            button.action = #selector(self.statusItemClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        

        evc = EditorViewController(nibName: "EditorViewController", bundle: nil)
        popover.contentViewController = evc
        
        
        //This is bad and you should feel bad
        togglePopover(nil)
        togglePopover(nil)

        //HANDLE right click https://github.com/craigfrancis/datetime/blob/master/xcode/DateTime/AppDelegate.swift


        //Handle when smart quotes is turned on or off in the view
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"SmartQuotesWasTurnedOn"), object:nil, queue:nil, using:smartQuotesWasTurnedOn)
        nc.addObserver(forName:Notification.Name(rawValue:"SmartQuotesWasTurnedOff"), object:nil, queue:nil, using:smartQuotesWasTurnedOff)
        
        setupHotKeys()
    }
    

    
    func statusItemClicked(sender: NSStatusBarButton!){
        let event:NSEvent! = NSApp.currentEvent!
        if (event.type == NSEventType.rightMouseUp) {
            closePopover(sender: nil)
            
            statusItem.highlightMode = true // Highlight bodge: Stop the highlight flicker (see async call below).
            statusItem.button?.isHighlighted = true
            
            let contextMenu = NSMenu();
            smart_quote_menu_item = NSMenuItem(title: "Smart Quotes", action: #selector(self.toggleSmartQuotes(sender:)), keyEquivalent: "")
            
            if (UserDefaults.standard.bool(forKey:"use_smart_quotes")){
                smart_quote_menu_item.state = NSOnState
            }else{
                smart_quote_menu_item.state = NSOffState
            }
            contextMenu.addItem(smart_quote_menu_item)
            contextMenu.addItem(NSMenuItem.separator())
            contextMenu.addItem(NSMenuItem(title: "Quit", action: #selector(self.quit(sender:)), keyEquivalent: "q"))
            
            statusItem.menu = contextMenu
            statusItem.popUpMenu(contextMenu)
            statusItem.menu = nil // Otherwise clicks won't be processed again
        }
        else{
            //statusItemClicked(sender:)
            togglePopover(sender)
        }
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
    
    func quit(sender: AnyObject?) {
        NSApplication.shared().terminate(nil)
    }

    func toggleSmartQuotes(sender: AnyObject?){
        /*let use_smart_quotes = UserDefaults.standard.bool(forKey:"use_smart_quotes")

        
        if (use_smart_quotes){
            smart_quote_menu_item.state = NSOffState
        }else{
            smart_quote_menu_item.state = NSOnState
        }*/
        
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"ToggleSmartQuotes"),
                object: nil,
                userInfo: ["message":"Hello there!", "date":Date()])
    }
    
    
    func smartQuotesWasTurnedOn(notification:Notification) -> Void{
        if let sqmi = smart_quote_menu_item {
            sqmi.state = NSOnState
        }
        UserDefaults.standard.set(true, forKey: "use_smart_quotes")

    }
    func smartQuotesWasTurnedOff(notification:Notification) -> Void{
        if let sqmi = smart_quote_menu_item {
            sqmi.state = NSOnState
        }
        UserDefaults.standard.set(false, forKey: "use_smart_quotes")
    }
    
    func setupHotKeys(){
        self.hotKey = HotKey(key: .r, modifiers: [.command, .option])
        self.hotKey.keyDownHandler = {
            self.togglePopover(nil)
        }
    }
}

