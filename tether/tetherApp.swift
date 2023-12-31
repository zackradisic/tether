//
//  tetherApp.swift
//  tether
//
//  Created by Zack Radisic on 06/06/2023.
//

import SwiftUI

class OverlayWindow: NSWindow {
    static var shared: OverlayWindow?
    
    init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        self.backgroundColor = NSColor.clear
        self.level = .screenSaver
        self.isOpaque = false
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.ignoresMouseEvents = false;
        OverlayWindow.shared = self
        self.becomeFirstResponder()
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        print("(OverlayWindow) EVENT \(event)")
        // Handle keydown events here
        super.keyDown(with: event)
    }
}

struct OverlayWindowView: NSViewRepresentable {
    @Binding var isOverlayVisible: Bool
    @Binding var pos: CGPoint?
    @Binding var size: CGSize?
    
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async { // ensure UI updates are on the main thread.
            let rect: NSRect
            if let pos = self.pos, let size = self.size {
                rect = NSRect(origin: pos, size: size)
            } else {
                rect = nsView.bounds
            }
            
            if let overlayWindow = OverlayWindow.shared {
                overlayWindow.setFrame(rect, display: isOverlayVisible)
                let hostingView = NSHostingView(rootView: ContentView2(pos: $pos, size: $size))
                overlayWindow.contentView = hostingView
                if isOverlayVisible {
                    overlayWindow.ignoresMouseEvents = false;
                    overlayWindow.makeKeyAndOrderFront(nil)
                    overlayWindow.makeMain()
                    overlayWindow.becomeKey()
                    NSApp.activate(ignoringOtherApps: true)
                } else {
                    overlayWindow.orderOut(nil)
                }
            } else {
                let overlayWindow = OverlayWindow(contentRect: rect)
                overlayWindow.contentView = NSHostingView(rootView: ContentView2(pos: $pos, size: $size))
                if isOverlayVisible {
                    overlayWindow.ignoresMouseEvents = false;
                    overlayWindow.makeKeyAndOrderFront(nil)
                    overlayWindow.makeMain()
                    overlayWindow.becomeKey()
                    NSApp.activate(ignoringOtherApps: true)
                } else {
                    overlayWindow.orderOut(nil)
                }
            }
        }
        return nsView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { // ensure UI updates are on the main thread.
            if let overlayWindow = OverlayWindow.shared {
                if isOverlayVisible {
                    let rect: NSRect
                    if let pos = self.pos, let size = self.size {
                        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 800, height: 600)
                        let actualPos = CGPoint(x: pos.x, y: screenSize.height - pos.y - size.height)
                        rect = NSRect(origin:actualPos, size: size)
                    } else {
                        rect = nsView.bounds
                    }
                    overlayWindow.setFrame(rect, display: isOverlayVisible)
                    overlayWindow.makeKeyAndOrderFront(nil)
                } else {
                    overlayWindow.orderOut(nil)
                }
            }
        }
    }
}

struct ContentView2: View {
    @Binding var pos: CGPoint?
    @Binding var size: CGSize?
    
    var body: some View {
        EditorViewRepresentable(pos: $pos, size: $size)
    }
}

@main
struct tetherApp: App {
    @ObservedObject var tetherState = TetherState()
    @State var pos: CGPoint? = CGPoint(x: 200.0, y: 200.0)
    @State var size: CGSize? = CGSize(width: 200.0, height: 200.0)
    
    init() {
        tetherState.start()
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("Main Window")
                if tetherState.isOverlayVisible {
                    OverlayWindowView(isOverlayVisible: $tetherState.isOverlayVisible, pos: $tetherState.position, size: $tetherState.size)
                }
            }
        }
    }
}

extension KeyEquivalent: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.character == rhs.character
    }
}

struct KeyEventHandling: NSViewRepresentable {
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            print(">> key \(event.charactersIgnoringModifiers ?? "")")
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
