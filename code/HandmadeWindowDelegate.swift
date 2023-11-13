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

    init(onWindowWillClose: @escaping () -> Void?) {
        self.onWindowWillClose = onWindowWillClose
    }

    func windowWillClose(_ notification: Notification) {
        onWindowWillClose()
    }
}
