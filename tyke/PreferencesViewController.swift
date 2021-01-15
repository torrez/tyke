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
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        
        self.hotKeyString = "Click to change"
        self.hotKeyClipboardString = "Click to change"
        
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
        var buttonText: String = ""
        
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


