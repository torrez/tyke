//
//  PreferencesViewController.swift
//  tyke
//
//  Created by Andre Torrez on 9/20/17.
//  Copyright © 2017 Andre Torrez. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet var btnHotKey: NSButton!
    @IBOutlet var btnHotKeyClipboard: NSButton!
    
    var isSettingHotkey: Bool = false
    var hotKeyClipboardString: String = ""
    var hotKeyString: String = ""
    var activeButton: NSButton!
    var textBtn = "Click to change"
    var textClipboardBtn = "Click to change"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.title = "Preferences"
        
        let showHotKeyCode: UInt32 = (HotKeysController.hotKeys[1]?.hotKey?.keyCombo.carbonKeyCode)!
        let showHotKeyModifiers: UInt32 = (HotKeysController.hotKeys[1]?.hotKey?.keyCombo.carbonModifiers)!
        let clipHotKeyCode: UInt32 = (HotKeysController.hotKeys[2]?.hotKey?.keyCombo.carbonKeyCode)!
        let clipHotKeyModifiers: UInt32 = (HotKeysController.hotKeys[2]?.hotKey?.keyCombo.carbonModifiers)!
        
        //self.hotKeyString = String(showHotKeyModifiers) + " " + String(showHotKeyCode)
        //self.hotKeyClipboardString = String(clipHotKeyModifiers) + " " + String(clipHotKeyCode)
        
        let commandSymbol:String = "\u{2318}"
        let optionSymbol:String = "\u{2325}"
        let controlSymbol:String = "\u{2303}"
        let shiftSymbol:String = "\u{21E7}"
        let separator:String = " + "
        
        let showUsesCommand:Bool = (showHotKeyModifiers & 256) != 0
        let showUsesOption:Bool = (showHotKeyModifiers & 2048) != 0
        let showUsesControl:Bool = (showHotKeyModifiers & 4096) != 0
        let showUsesShift:Bool = (showHotKeyModifiers & 512) != 0
        
        let clipUsesCommand:Bool = (clipHotKeyModifiers & 256) != 0
        let clipUsesOption:Bool = (clipHotKeyModifiers & 2048) != 0
        let clipUsesControl:Bool = (clipHotKeyModifiers & 4096) != 0
        let clipUsesShift:Bool = (clipHotKeyModifiers & 512) != 0
        
        var showDisplay:String = ""
        
        if (showUsesCommand) { showDisplay += commandSymbol + separator }
        if (showUsesOption) { showDisplay += optionSymbol + separator }
        if (showUsesControl) { showDisplay += controlSymbol + separator }
        if (showUsesShift) { showDisplay += shiftSymbol + separator }
        
        var clipDisplay:String = ""
        
        if (clipUsesCommand) { clipDisplay += commandSymbol + separator }
        if (clipUsesOption) { clipDisplay += optionSymbol + separator }
        if (clipUsesControl) { clipDisplay += controlSymbol + separator }
        if (clipUsesShift) { clipDisplay += shiftSymbol + separator }
        
        self.hotKeyString = showDisplay + String(showHotKeyCode)
        self.hotKeyClipboardString = clipDisplay + String(clipHotKeyCode)
        
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        // TODO: Eventually I want to bring the HotKey code in using the Swift Package Manager
        
        //self.hotKeyString = "Click to change"
        //self.hotKeyClipboardString = "Click to change"
        
        // Pull strings from user defaults to override above
        
        setupButtonStrings()
    }

    
    @IBAction func hotKeyBtnClipClick(_ sender: NSButton) {
        self.activeButton = sender
        self.isSettingHotkey = true
            
    }
    @IBAction func hotKeyBtnClick(_ sender: NSButton) {
        self.activeButton = sender
        self.isSettingHotkey = true
    }
    
    //override func flagsChanged(with event: NSEvent) {
    //}
    
    func setupButtonStrings() {
        
        btnHotKey.title = hotKeyString
        btnHotKeyClipboard.title = hotKeyClipboardString
    }
    
    func makeButtonString(event: NSEvent) -> String {
        let buttonText: String = ""
        
        return buttonText
    }
    override func keyDown(with event: NSEvent) {
        
        if (!self.isSettingHotkey) {
            return
        }
        
        var newButtonString:String = ""
        
        if (event.keyCode == 53) {
            self.isSettingHotkey = false
            self.setupButtonStrings()
            return
        }
        print("Key: " + event.charactersIgnoringModifiers!)
        
        let x = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        
        
        if (!x.contains(.control)) && (!x.contains(.option)) && (!x.contains(.command)){
            NSSound(named: "Funk")?.play()
            return
        }
        if x.contains(.control){
            newButtonString += "⌃"
        }
        if x.contains(.option){
            newButtonString += "⌥"
        }
        if x.contains(.command){
            newButtonString += "⌘"
        }
        if x.contains(.shift){
            newButtonString += "⇧"
        }
        
        if let character:String = event.charactersIgnoringModifiers {
            newButtonString += character
        }
        
        if (self.activeButton == btnHotKeyClipboard){
            btnHotKeyClipboard.title = newButtonString
        }else if(self.activeButton == btnHotKey){
            btnHotKey.title = newButtonString
        }
        
        //Set up this hot key!
        if let newHotKey:Key = Key(string:event.charactersIgnoringModifiers!){
            
            let hotKey = HotKey(key: newHotKey, modifiers: event.modifierFlags)
            hotKey.keyDownHandler = {
                print("do a popup")
            }
        }
        
        //Store hot key in preferences
        
        isSettingHotkey = false
    }
    
}


