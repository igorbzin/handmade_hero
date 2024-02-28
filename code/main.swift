//
//  main.swift
//  hand_made
//
//  Created by Igor Bozin on 31.10.23.
//

import AppKit

public enum App
{
    public static func main()
    {
        var running = false

        let globalRenderingWidth: Double = 1024
        let globalRenderingHeight: Double = 768

        let screenRect = NSScreen.main?.frame

        let x = (screenRect?.width ?? 0.0) - globalRenderingWidth * 0.5
        let y = (screenRect?.height ?? 0.0) - globalRenderingHeight * 0.5

        let content: NSRect = .init(x: x, y: y, width: globalRenderingWidth, height: globalRenderingHeight)
        let window: NSWindow = .init(contentRect: content,
                                     styleMask: NSWindow.StyleMask.titled.union(
                                         NSWindow.StyleMask.closable.union(
                                             NSWindow.StyleMask.resizable.union(NSWindow.StyleMask.miniaturizable)
                                         )
                                     ),
                                     backing: NSWindow.BackingStoreType.buffered,
                                     defer: false)

        window.backgroundColor = NSColor.systemBlue
        window.title = "Handmade Hero"
        window.makeKeyAndOrderFront(nil)

        var bitmapWidth: Int
        var bitmapHeight: Int

        if let width = window.contentView?.frame.width
        {
            bitmapWidth = Int(width)
        } else
        {
            bitmapWidth = 0
        }

        if let height = window.contentView?.frame.height
        {
            bitmapHeight = Int(height)
        } else
        {
            bitmapHeight = 0
        }
        let handmadeWindowDelegate: HandmadeWindowDelegate = HandmadeWindowDelegateImpl(onWindowDidResize: { [weak window] in
            guard let window = window else { return }

            if let width = window.contentView?.frame.width
            {
                bitmapWidth = Int(width)
            } else
            {
                bitmapWidth = 0
            }

            if let height = window.contentView?.frame.height
            {
                bitmapHeight = Int(height)
            } else
            {
                bitmapHeight = 0
            }

            resizeDIBSection(window: window, width: bitmapWidth, height: bitmapHeight)
        })
        {
            running = false
            print("Window is about to close")
        }

        window.delegate = handmadeWindowDelegate

        let bytesPerPixel = 4
        let pitch = bytesPerPixel * bitmapWidth

        let bufferSize = pitch * bitmapHeight
        var buffer = [UInt8](repeating: 0, count: bufferSize) // Initialize the buffer with zeros

        let rowsToModify = bitmapHeight / 2

        // Iterate over the upper half of the bitmap
        for y in 0 ..< rowsToModify
        {
            for x in 0 ..< bitmapWidth
            {
                // Calculate the index for the red component of the current pixel
                // The pitch accounts for the total number of bytes per row in the bitmap
                let redIndex = y * pitch + x * bytesPerPixel

                // Set the pixel's color to fully opaque red (R=255, G=0, B=0, A=255)
                buffer[redIndex] = 255 // R
                buffer[redIndex + 1] = 0 // G
                buffer[redIndex + 2] = 0 // B
                buffer[redIndex + 3] = 255 // A (alpha component set to fully opaque)
            }
        }

        let red: UInt8 = 255
        let blue: UInt8 = 0
        let green: UInt8 = 0
        let alpha: UInt8 = 255

        running = true

        while running
        {
            autoreleasepool
            {
                buffer.withUnsafeMutableBytes
                { rawBufferPointer in
                    // Ensure we have a base address to work with
                    guard let baseAddress = rawBufferPointer.baseAddress else { return }

                    // Convert to the correct type, making it an optional pointer
                    let baseAddressAsUInt8Optional = baseAddress.assumingMemoryBound(to: UInt8.self)

                    // Now, create a pointer to this optional pointer
                    var planes: UnsafeMutablePointer<UInt8>? = baseAddressAsUInt8Optional

                    // Pass the address of planes to the initializer
                    let bitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: &planes,
                                                          pixelsWide: bitmapWidth,
                                                          pixelsHigh: bitmapHeight,
                                                          bitsPerSample: 8,
                                                          samplesPerPixel: bytesPerPixel,
                                                          hasAlpha: true,
                                                          isPlanar: false,
                                                          colorSpaceName: NSColorSpaceName.deviceRGB,
                                                          bytesPerRow: pitch,
                                                          bitsPerPixel: 32)

                    let image = NSImage(size: NSMakeSize(CGFloat(bitmapWidth), CGFloat(bitmapHeight)))

                    if let unwrapped = bitmapImageRep
                    {
                        image.addRepresentation(unwrapped)
                        window.contentView?.layer?.contents = image
                    } else
                    {
                        print("BitmapImageRep is nil")
                    }
                }
            }

            var event: NSEvent?
            repeat
            {
                event = NSApp.nextEvent(matching: .any,
                                        until: nil,
                                        inMode: .default,
                                        dequeue: true)

                switch event?.type
                {
                // ... (some cases might handle specific event types)
                default:
                    if let validEvent = event
                    {
                        NSApp.sendEvent(validEvent)
                    }
                }
            } while event != nil
        }
    }

    static func resizeDIBSection(window _: NSWindow, width _: Int?, height _: Int?) {}
}

App.main()
