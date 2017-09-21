//
//  EditorViewController.swift
//  tyke
//
//  Created by Andre Torrez on 8/17/17.
//  Copyright © 2017 Andre Torrez. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet var editor: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        self.editor.font = NSFont(name:"Menlo", size:16)
        self.editor.textContainerInset =  NSSize(width: 9.0, height: 9.0)
        self.editor.delegate = self
        
        
        let nc = NotificationCenter.default
        nc.addObserver(forName:Notification.Name(rawValue:"ToggleSmartQuotes"),
                       object:nil, queue:nil,
                       using:didToggleSmartQuotes)

        // Should smart quotes be on or off?
        if (UserDefaults.standard.bool(forKey:"use_smart_quotes")){
            self.editor.isAutomaticQuoteSubstitutionEnabled = true
        }else{
            self.editor.isAutomaticQuoteSubstitutionEnabled = false
        }
        
        addObserver(self, forKeyPath: #keyPath(editor.isAutomaticQuoteSubstitutionEnabled), options: [.old, .new], context: nil)
    }
    
    // Observe if smart quotes were turned off.

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(editor.isAutomaticQuoteSubstitutionEnabled) {
            
            //Post notification that it was turned on
            if (self.editor.isAutomaticQuoteSubstitutionEnabled){
                let nc = NotificationCenter.default
                nc.post(name:Notification.Name(rawValue:"SmartQuotesWasTurnedOn"),
                        object: nil,
                        userInfo: nil)
            }else{
                let nc = NotificationCenter.default
                nc.post(name:Notification.Name(rawValue:"SmartQuotesWasTurnedOff"),
                        object: nil,
                        userInfo: nil)
            
            }
        }
    }
    
    
    func didToggleSmartQuotes(notification:Notification) -> Void{
        self.editor.toggleAutomaticQuoteSubstitution(nil)
    }
    

}
