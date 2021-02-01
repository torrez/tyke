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
    let statusItem = NSStatusBar.system.statusItem(withLength: -2)
    
    var evc: EditorViewController!
    var pvc: PreferencesViewController!
    var pasteboard = NSPasteboard.general
    var smart_quote_menu_item: NSMenuItem!
    var showHotKey: HotKey?
    var clipboardHotKey: HotKey?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        popover.behavior = NSPopover.Behavior.transient
        popover.animates = false
        
        if let button = statusItem.button {
            button.image = NSImage(named: "dabutton")
            button.image?.size = NSSize(width: 20, height: 18)
            button.image?.isTemplate = true
            button.action = #selector(self.statusItemClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        evc = EditorViewController(nibName: "EditorViewController", bundle: nil)
        popover.contentViewController = evc
        
        pvc = PreferencesViewController(nibName: "PreferencesViewController", bundle:nil)

        //This is bad and you should feel bad
        togglePopover(nil)
        togglePopover(nil)

        //HANDLE right click https://github.com/craigfrancis/datetime/blob/master/xcode/DateTime/AppDelegate.swift

        //Handle when smart quotes is turned on or off in the view
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"SmartQuotesWasTurnedOn"), object:nil, queue:nil, using:smartQuotesWasTurnedOn)
        nc.addObserver(forName:Notification.Name(rawValue:"SmartQuotesWasTurnedOff"), object:nil, queue:nil, using:smartQuotesWasTurnedOff)
        
        setupHotKeys()
        handleHotKeys()
    }
    
    @objc func statusItemClicked(sender: NSStatusBarButton!){
        
        let event:NSEvent! = NSApp.currentEvent!
        if (event.type == NSEvent.EventType.rightMouseUp) {
            closePopover(sender: nil)
            
            statusItem.highlightMode = true // Highlight badge: Stop the highlight flicker (see async call below).
            statusItem.button?.isHighlighted = true
            
            let contextMenu = NSMenu()
            smart_quote_menu_item = NSMenuItem(title: "Smart Quotes", action: #selector(self.toggleSmartQuotes(sender:)), keyEquivalent: "")
            
            if (UserDefaults.standard.bool(forKey:"use_smart_quotes")) { smart_quote_menu_item.state = NSControl.StateValue.on }
            else { smart_quote_menu_item.state = NSControl.StateValue.off }
            
            contextMenu.addItem(smart_quote_menu_item)
            contextMenu.addItem(NSMenuItem(title: "Hot Keys", action: #selector(self.showPreferences(sender:)), keyEquivalent: ""))
            contextMenu.addItem(NSMenuItem.separator())
            contextMenu.addItem(NSMenuItem(title: "Quit", action: #selector(self.quit(sender:)), keyEquivalent: ""))
            
            statusItem.menu = contextMenu
            statusItem.popUpMenu(contextMenu)
            statusItem.menu = nil // Otherwise clicks won't be processed again
        }
        else { togglePopover(sender) }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func showPopover(sender: AnyObject?) {
        
        if let button = statusItem.button {
            NSApplication.shared.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: AnyObject?) {
        
        popover.performClose(sender)
    }
    
    func togglePopover(_ sender: AnyObject?) {
        
        if popover.isShown { closePopover(sender:sender) }
        else { showPopover(sender:sender) }
    }
    
    @objc func quit(sender: AnyObject?) {
        
        NSApplication.shared.terminate(nil)
    }

    @objc func toggleSmartQuotes(sender: AnyObject?) {
        
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"ToggleSmartQuotes"),
                object: nil,
                userInfo: ["message":"Hello there!", "date":Date()])
    }
    
    @objc func showPreferences(sender: AnyObject?) {
        
        pvc.presentAsModalWindow(pvc)
    }
    
    func smartQuotesWasTurnedOn(notification:Notification) -> Void {
        
        if let sqmi = smart_quote_menu_item {
            sqmi.state = NSControl.StateValue.on
        }
        
        UserDefaults.standard.set(true, forKey: "use_smart_quotes")
    }
    
    func smartQuotesWasTurnedOff(notification:Notification) -> Void {
        
        if let sqmi = smart_quote_menu_item {
            sqmi.state = NSControl.StateValue.off
        }
        UserDefaults.standard.set(false, forKey: "use_smart_quotes")
    }
    
    func setupHotKeys() {
        // Set show and Clipboard hotkeys to initial values
        
        showHotKey = HotKey(keyCombo: KeyCombo(key: .s, modifiers: [.command, .option]))
        clipboardHotKey = HotKey(keyCombo: KeyCombo(key: .c, modifiers: [.command, .option]))
    }
    
    func handleHotKeys() {
        
        self.showHotKey?.keyDownHandler = { self.togglePopover(nil) }
        
        self.clipboardHotKey?.keyDownHandler = {
            
            let textToCopy: [NSString] = NSArray.init(object: self.evc.editor.textStorage!.string) as! [NSString]
            
            self.pasteboard.clearContents()
            self.pasteboard.writeObjects(textToCopy)
        }
    }
}

