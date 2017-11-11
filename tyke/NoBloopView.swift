//
//  NoBloopView.swift
//  tyke
//
//  Created by Andre Torrez on 9/21/17.
//  Copyright © 2017 Andre Torrez. All rights reserved.
//

import Cocoa

class NoBloopView: NSView {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
}

