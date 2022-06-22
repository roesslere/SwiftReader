//
//  swiftreaderApp.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 9/1/21.
//

import SwiftUI
import ServiceManagement
import KeyboardShortcuts
import LaunchAtLogin

class WindowGlobals: ObservableObject
{
	@Published public var StatusBarMenu: NSMenu?
	@Published public var SnapWindow: NSWindow?
	@Published public var PreferencesWindow: NSWindow?
	@Published public var HelpWindow: NSWindow?
}

class SnapWindow: NSWindow, NSWindowDelegate
{
	override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool)
	{
		super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
		AppDelegate = nil
	}
	var AppDelegate: AppDelegate?
	
	override var canBecomeKey: Bool {get{return true}}
	override var acceptsFirstResponder: Bool {get{return true}}
	
	override func performKeyEquivalent(with event: NSEvent) -> Bool
	{
		super.performKeyEquivalent(with: event)
		return true
	}
	@objc override func keyUp(with event: NSEvent)
	{
		super.keyUp(with: event)
		if (event.keyCode == 53)
		{
			AppDelegate!.CloseSnapWindow(self)
		}
	}
	
	func SetAppDelegate(AppDelegate: AppDelegate)
	{
		self.AppDelegate = AppDelegate
	}
}

@objc class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject
{
	override init()
	{
		Windows = WindowGlobals()
		SnapWindow = nil
		View = ContentView()
		StatusBar = nil
	}
	@ObservedObject public var Windows: WindowGlobals
	public var SnapWindow: SnapWindow?
	private var View: ContentView?
	private var StatusBar: StatusBarController?
	
	// Allows global reference of AppDelegate while using @NSApplicationDelegateAdaptor
	@Environment(\.AppDelegate) public static var SharedDelegate
	
	func applicationDidFinishLaunching(_ notification: Notification)
	{
		StatusBar = StatusBarController.init(AppDelegate: self)

		if (CGPreflightScreenCaptureAccess() == false)
		{
			CGRequestScreenCaptureAccess()
		}
		
		if (UserPreferences.g_UserPreferences().bool(forKey: "bPlayTutorial") == true)
		{
			StatusBar?.HelpSelect(self)
			NSApp.activate(ignoringOtherApps: true)
			UserPreferences.g_UserPreferences().setValue(false, forKey: "bPlayTutorial")
		}
		
		View!.SetAppDelegate(AppDelegate: self)
		
		SnapWindow = swiftreader.SnapWindow(contentRect: NSScreen.main!.frame, styleMask: .borderless, backing: .buffered, defer: false, screen: NSScreen.main)
		SnapWindow!.SetAppDelegate(AppDelegate: self)
		SnapWindow!.level = NSWindow.Level(Int(CGWindowLevelForKey(.maximumWindow)))
		SnapWindow!.contentView = NSHostingView(rootView: View!)
		SnapWindow!.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.0)
		SnapWindow!.setIsVisible(false)
		Windows.SnapWindow = SnapWindow
		
		KeyboardShortcuts.onKeyUp(for: .ToggleSnap) { [self] in
			ToggleSnapWindow(self)
		}
	}
	
	func applicationWillTerminate(_ notification: Notification)
	{
		
	}
	
	func SetSnapView(View: ContentView)
	{
		self.View = View
	}
	
	@objc func ToggleSnapWindow(_ sender: Any)
	{
		if (SnapWindow!.isVisible)
		{
			CloseSnapWindow(sender)
		}
		else
		{
			OpenSnapWindow(sender)
		}
	}
	
	@objc func OpenSnapWindow(_ sender: Any)
	{
		SnapWindow!.setFrameOrigin(CGPoint(x: NSScreen.main!.frame.width / 2 - SnapWindow!.frame.width / 2, y: NSScreen.main!.frame.height / 2 - SnapWindow!.frame.height / 2))
		WindowHandler.OpenWindow(Window: SnapWindow!)
		SnapWindow!.makeKeyAndOrderFront(nil)
		
		// Close other windows
		if (Windows.PreferencesWindow != nil && Windows.PreferencesWindow!.isVisible)
		{
			WindowHandler.CloseWindow(Window: Windows.PreferencesWindow!)
		}
		if (Windows.HelpWindow != nil && Windows.HelpWindow!.isVisible)
		{
			WindowHandler.CloseWindow(Window: Windows.HelpWindow!)
		}
	}
	
	@objc func CloseSnapWindow(_ sender: Any)
	{
		WindowHandler.CloseWindow(Window: SnapWindow!, CloseAction: { Window in
			Window.setIsVisible(false)
		})
		self.View!.Reset()
	}
	
	// If user didn't allow Screen Record permissions
	@objc func CloseSnapWindowAndShowPermissions(_ sender: Any)
	{
		WindowHandler.CloseWindow(Window: SnapWindow!, CloseAction: { Window in
			Window.setIsVisible(false)
			self.DisplayPermissionsAlert()
		})
	}
	
	func DisplayPermissionsAlert()
	{
		let AlertController = NSAlert()
		AlertController.messageText = "Screen Record Permission Required"
		AlertController.informativeText = "SwiftReader requires the Screen Recording permission to recognize text."
		AlertController.alertStyle = .warning
		AlertController.addButton(withTitle: "OK")
		AlertController.addButton(withTitle: "Cancel")
		let Modal = AlertController.runModal()
		switch Modal
		{
			case .alertFirstButtonReturn:
				NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
			default:
				break
		}
	}
}

struct Delegate: EnvironmentKey
{
	static public let defaultValue: AppDelegate = AppDelegate()
}

extension EnvironmentValues
{
	var AppDelegate: Delegate.Value
	{
		get {
			return self[Delegate.self]
		}
		set {
			self[Delegate.self] = newValue
		}
	}
}
