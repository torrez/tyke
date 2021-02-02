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
    
    let appDelegate = NSApp.delegate as! AppDelegate
    
    let commandSymbol:String = "\u{2318}" // ⌘
    let optionSymbol:String = "\u{2325}"  // ⌥
    let controlSymbol:String = "\u{2303}" // ⌃
    let shiftSymbol:String = "\u{21E7}"   // ⇧
    let separator:String = " + "
    
    var isSettingHotKey: Bool = false
    var showDisplayString:String = ""
    var clipDisplayString:String = ""
    var activeButton: NSButton!
    
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
        
        self.activeButton = sender
        self.activeButton.title = ""
        
        self.isSettingHotKey = true
    }
    
    @IBAction func btnShowHotKey(_ sender: NSButton) {
        
        self.activeButton = sender
        self.activeButton.title = ""
        self.isSettingHotKey = true
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
        
        if (!self.isSettingHotKey) { return }
        
        var newButtonString:String = ""
        
        if (event.keyCode == 53) {          // 53 = 0x35 = kVK_Escape
            self.isSettingHotKey = false
            self.setupButtonStrings()
            return
        }
        
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
        
        if (self.activeButton == btnShowHotKey) {
            btnShowHotKey.title = newButtonString
            if let newHotKey:Key = Key(string:event.charactersIgnoringModifiers!) {
                self.appDelegate.showHotKey = HotKey(key: newHotKey, modifiers: event.modifierFlags)
                self.appDelegate.showHotKey?.keyDownHandler = { self.appDelegate.togglePopover(nil) } // Can I somehow reference the code in AppDelegate instead of have to repeat here?
            }
        }
        else if (self.activeButton == btnClipHotKey) {
            btnClipHotKey.title = newButtonString
            if let newHotKey:Key = Key(string:event.charactersIgnoringModifiers!) {
                self.appDelegate.clipboardHotKey = HotKey(key: newHotKey, modifiers: event.modifierFlags)
                self.appDelegate.clipboardHotKey?.keyDownHandler = { // Can I somehow reference the code in AppDelegate instead of have to repeat here?
                    let textToCopy: [NSString] = NSArray.init(object: self.appDelegate.evc.editor.textStorage!.string) as! [NSString]
                    self.appDelegate.pasteboard.clearContents()
                    self.appDelegate.pasteboard.writeObjects(textToCopy)
                }
            }
        }
        
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
        isSettingHotKey = false
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


