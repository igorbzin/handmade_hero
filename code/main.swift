//
//  Main.swift
//  hand_made
//
//  Created by Igor Bozin on 31.10.23.
//

import AppKit

var running: Bool = false

let globalRenderingWidth: Double = 1024
let globalRenderingHeight: Double = 768

let screenRect = NSScreen.main?.frame

let x = (screenRect?.width ?? 0.0) - globalRenderingWidth * 0.5
let y = (screenRect?.height ?? 0.0) - globalRenderingHeight * 0.5

let content: NSRect = .init(x: x, y: y, width: globalRenderingWidth, height: globalRenderingHeight)
let window: NSWindow = .init(contentRect: content, styleMask: NSWindow.StyleMask.titled.union(NSWindow.StyleMask.closable.union(NSWindow.StyleMask.resizable.union(NSWindow.StyleMask.miniaturizable))), backing: NSWindow.BackingStoreType.buffered, defer: false)

window.backgroundColor = NSColor.systemBlue
window.title = "Handmade Hero"
window.makeKeyAndOrderFront(nil)

running = true

let handmadeWindowDelegate: HandmadeWindowDelegate = HandmadeWindowDelegateImpl {
    running = false
    print("Window is about to close")
}


window.delegate = handmadeWindowDelegate

while running {
    var event: NSEvent?
    repeat {
        event = NSApp.nextEvent(matching: .any,
                                until: nil,
                                inMode: .default,
                                dequeue: true)

        switch event?.type {
        // ... (some cases might handle specific event types)
        default:
            if let validEvent = event {
                NSApp.sendEvent(validEvent)
            }
        }
    } while event != nil
}

print("Handmade hero was run successfully!")
