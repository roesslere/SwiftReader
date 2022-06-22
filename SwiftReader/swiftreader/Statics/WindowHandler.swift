//
//  WindowHandler.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 9/26/21.
//

import AppKit

struct WindowHandler
{
	static func OpenWindow(Window: NSWindow, AnimationDuration: TimeInterval = 0.3)
	{
		Window.setIsVisible(true)
		Window.makeKeyAndOrderFront(self)
		Window.orderedIndex = 0
		NSApplication.shared.activate(ignoringOtherApps: true)
		Window.alphaValue = 0
		NSAnimationContext.runAnimationGroup({ Ctx in
			Ctx.duration = AnimationDuration
			Window.animator().alphaValue = 1
		})
	}
	static func CloseWindow(Window: NSWindow, AnimationDuration: TimeInterval = 0.3)
	{
		CloseWindow(Window: Window, CloseAction: { Window in
			Window.setIsVisible(false)
			Window.close()
			Window.contentView = nil
		} )
	}
	static func CloseWindow(Window: NSWindow, CloseAction: @escaping (NSWindow) -> Void, AnimationDuration: TimeInterval = 0.3)
	{
		Window.alphaValue = 1
		NSAnimationContext.runAnimationGroup({ Ctx in
			Ctx.duration = AnimationDuration
			Window.animator().alphaValue = 0
		}, completionHandler: {
			CloseAction(Window)
		})
	}
}
