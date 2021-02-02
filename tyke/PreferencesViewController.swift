//
//  PreferencesViewController.swift
//  tyke
//
//  Created by Andre Torrez on 9/20/17.
//  Copyright © 2017 Andre Torrez. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet var btnShowHotKey:NSButton!
    @IBOutlet var btnClipHotKey:NSButton!

    
    let commandSymbol:String = "\u{2318}" // ⌘
    let optionSymbol:String = "\u{2325}"  // ⌥
    let controlSymbol:String = "\u{2303}" // ⌃
    let shiftSymbol:String = "\u{21E7}"   // ⇧
    let separator:String = " + "
    
    var isSettingHotkey: Bool = false
    var showDisplayString:String = ""
    var clipDisplayString:String = ""
    var activeButton: NSButton!
    var textBtn = "Click to change"
    var textClipboardBtn = "Click to change"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Hot Keys"
        
        let showHotKeyCode: UInt32 = (HotKeysController.hotKeys[1]?.hotKey?.keyCombo.carbonKeyCode)!
        let showHotKeyModifiers: UInt32 = (HotKeysController.hotKeys[1]?.hotKey?.keyCombo.carbonModifiers)!
        let clipHotKeyCode: UInt32 = (HotKeysController.hotKeys[2]?.hotKey?.keyCombo.carbonKeyCode)!
        let clipHotKeyModifiers: UInt32 = (HotKeysController.hotKeys[2]?.hotKey?.keyCombo.carbonModifiers)!
        
        showDisplayString = createHotKeyDisplayString(key: showHotKeyCode, modifiers: showHotKeyModifiers)
        clipDisplayString = createHotKeyDisplayString(key: clipHotKeyCode, modifiers: clipHotKeyModifiers)
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        // TODO: Eventually I want to bring the HotKey code in from GitHub repo using the Swift Package Manager
        
        // Pull strings from user defaults to override above
        setupButtonStrings()
    }

    
    @IBAction func btnClipHotKey(_ sender: NSButton) {
        
        btnClipHotKey.title = ""
        self.activeButton = sender
        self.isSettingHotkey = true
            
    }
    @IBAction func btnShowHotKey(_ sender: NSButton) {
        
        btnShowHotKey.title = ""
        self.activeButton = sender
        self.isSettingHotkey = true
    }
    
    //override func flagsChanged(with event: NSEvent) {
    //}
    
    func setupButtonStrings() {
        
        btnShowHotKey.title = showDisplayString
        btnClipHotKey.title = clipDisplayString
    }
    
    func makeButtonString(event: NSEvent) -> String {
        
        let buttonText: String = ""
        return buttonText
    }
    
    override func keyDown(with event: NSEvent) {
        
        if (!self.isSettingHotkey) { return }
        
        var newButtonString:String = ""
        
        if (event.keyCode == 53) {          // 53 = 0x35 = kVK_Escape
            self.isSettingHotkey = false
            self.setupButtonStrings()
            return
        }
        
        print("Key: " + event.charactersIgnoringModifiers!)
        
        let x = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if (!x.contains(.command)) && (!x.contains(.option)) && (!x.contains(.control)) && (!x.contains(.shift)) {
            NSSound(named: "Funk")?.play()
            return
        }
        
        if x.contains(.command) { newButtonString += commandSymbol + separator }
        if x.contains(.option) { newButtonString += optionSymbol + separator }
        if x.contains(.control) { newButtonString += controlSymbol + separator }
        if x.contains(.shift) { newButtonString += shiftSymbol + separator }
        
        if let character:String = event.charactersIgnoringModifiers { newButtonString += character }
        
        if (self.activeButton == btnClipHotKey) { btnClipHotKey.title = newButtonString }
        else if(self.activeButton == btnShowHotKey) { btnShowHotKey.title = newButtonString }
        
        /*
        //Set up this hot key!
        if let newHotKey:Key = Key(string:event.charactersIgnoringModifiers!){
            
            let hotKey = HotKey(key: newHotKey, modifiers: event.modifierFlags)
            hotKey.keyDownHandler = {
                print("do a popup")
            }
        }
        
        //Store hot key in preferences
        */
        isSettingHotkey = false
    }
    
    func createHotKeyDisplayString(key: UInt32, modifiers: UInt32) -> String {
        
        var displayString: String = ""
        
        let usesCommand:Bool = (modifiers & 256) != 0
        let usesOption:Bool = (modifiers & 2048) != 0
        let usesControl:Bool = (modifiers & 4096) != 0
        let usesShift:Bool = (modifiers & 512) != 0
        
        if (usesCommand) { displayString += commandSymbol + separator }
        if (usesOption) { displayString += optionSymbol + separator }
        if (usesControl) { displayString += controlSymbol + separator }
        if (usesShift) { displayString += shiftSymbol + separator }
        
        displayString += String(describing: Key(carbonKeyCode: key)!)
        
        return displayString
    }
    
}


