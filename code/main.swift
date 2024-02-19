
//
//  main.swift
//  hand_made
//
//  Created by Igor Bozin on 31.10.23.
//

import AppKit

enum App {
    static func main() {
        var running = false

        let globalRenderingWidth: Double = 1024
        let globalRenderingHeight: Double = 768

        let screenRect = NSScreen.main?.frame

        let x = (screenRect?.width ?? 0.0) - globalRenderingWidth * 0.5
        let y = (screenRect?.height ?? 0.0) - globalRenderingHeight * 0.5

        let content: NSRect = .init(x: x, y: y, width: globalRenderingWidth, height: globalRenderingHeight)
        let window: NSWindow = .init(contentRect: content,
                                     styleMask: NSWindow.StyleMask.titled.union(
                                        NSWindow.StyleMask.closable.union(NSWindow.StyleMask.resizable.union(NSWindow.StyleMask.miniaturizable))
                                     ),
                                     backing: NSWindow.BackingStoreType.buffered,
                                     defer: false)

        window.backgroundColor = NSColor.systemBlue
        window.title = "Handmade Hero"
        window.makeKeyAndOrderFront(nil)

        var bitmapWidth = window.contentView?.frame.width ?? 0.0
        var bitmapHeight = window.contentView?.frame.height ?? 0.0

        let handmadeWindowDelegate: HandmadeWindowDelegate = HandmadeWindowDelegateImpl(onWindowDidResize: {
            bitmapWidth = window.contentView?.frame.width ?? 0.0
            bitmapHeight = window.contentView?.frame.height ?? 0.0

            resizeDIBSection(width: bitmapWidth, height: bitmapHeight)
        }) {
            running = false
            print("Window is about to close")
        }

        window.delegate = handmadeWindowDelegate

        let bytesPerPixel = 4
        let pitch = Int((CGFloat(bytesPerPixel) * bitmapWidth).rounded())

        let bufferSize = Int((CGFloat(pitch) * bitmapHeight).rounded())
        var buffer = [UInt8]()
        buffer.reserveCapacity(bufferSize)

        var planes: [[UInt8]] = [buffer]

        let red: UInt8 = 255
        let blue: UInt8 = 0
        let green: UInt8 = 0
        let alpha: UInt8 = 255

        running = true

        while running {
            autoreleasepool {
                buffer.withUnsafeMutableBytes { rawBufferPointer in
                    // Ensure we have a base address to work with
                    guard let baseAddress = rawBufferPointer.baseAddress else { return }

                    // Convert to the correct type, making it an optional pointer
                    let baseAddressAsUInt8Optional = baseAddress.assumingMemoryBound(to: UInt8.self)

                    // Now, create a pointer to this optional pointer
                    var planes: UnsafeMutablePointer<UInt8>? = baseAddressAsUInt8Optional

                    // Pass the address of planes to the initializer
                    let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: &planes,
                                                          pixelsWide: Int(bitmapWidth),
                                                          pixelsHigh: Int(bitmapHeight), 
                                                          bitsPerSample: 8,
                                                          samplesPerPixel: bytesPerPixel,
                                                          hasAlpha: true,
                                                          isPlanar: false,
                                                          colorSpaceName: NSColorSpaceName.deviceRGB,
                                                          bytesPerRow: pitch,
                                                          bitsPerPixel: 32)

                    let image = NSImage(size: NSMakeSize(bitmapWidth, bitmapHeight))

                    if let unwrapped = bitmapImageRep {
                        image.addRepresentation(unwrapped)
                        window.contentView?.layer?.contents = image
                    } else {
                        print("BitmapImageRep is nil")
                    }
                }
            }

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
    }


    func resizeDIBSection(window: NSWindow, width _: CGFloat?, height _: CGFloat?) {
        
    }
}

App.main()
