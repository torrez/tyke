//
//  EditorViewController.swift
//  tyke
//
//  Created by Andre Torrez on 8/17/17.
//  Copyright © 2017 Andre Torrez. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController {

    @IBOutlet var editor: NSTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

//        self.editor.backgroundColor = NSColor.red
//        self.editor.drawsBackground = true
        self.editor.font = NSFont(name:"Menlo", size:16)
        self.editor.textContainerInset =  NSSize(width: 9.0, height: 9.0)
    }
    
}
