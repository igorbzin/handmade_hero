//
//  HandmadeWindowDelegate.swift
//  hand_made
//
//  Created by Igor Bozin on 05.11.23.
//

import AppKit

protocol HandmadeWindowDelegate: NSWindowDelegate {}

class HandmadeWindowDelegateImpl: NSObject, HandmadeWindowDelegate {
    var onWindowWillClose: () -> Void?
    var onWindowDidResize: () -> Void?

    init(onWindowDidResize: @escaping () -> Void?, onWindowWillClose : @escaping () -> Void?) {
        self.onWindowDidResize = onWindowDidResize
        self.onWindowWillClose = onWindowWillClose
    }

    func windowDidResize(_ notification: Notification) {
        onWindowDidResize()
    }

    func windowWillClose(_ notification: Notification) {
        onWindowWillClose()
    }
}
