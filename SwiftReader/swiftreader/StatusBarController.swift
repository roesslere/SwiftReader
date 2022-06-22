//
//  StatusBarController.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 9/3/21.
//

import SwiftUI
import AppKit
import KeyboardShortcuts

class StatusBarController
{
	init(AppDelegate: AppDelegate)
	{
		self.AppDelegate = AppDelegate
		
		StatusBar = NSStatusBar.init()
		StatusItem = StatusBar.statusItem(withLength: 28.0)
		
		bWindowVisible = false
		
		let SnapItem = NSMenuItem(title: "Snap", action: #selector(AppDelegate.ToggleSnapWindow(_:)), keyEquivalent: "")
		let PreferencesItem = NSMenuItem(title: "Preferences", action:#selector(PreferencesSelect(_:)), keyEquivalent: "")
		let HelpItem = NSMenuItem(title: "Help", action:#selector(HelpSelect(_:)), keyEquivalent: "")
		let AboutItem = NSMenuItem(title: "About", action:#selector(AboutSelect(_:)), keyEquivalent: "")
		let QuitItem = NSMenuItem(title: "Quit", action:#selector(QuitSelect(_:)), keyEquivalent: "")
		
		PreferencesItem.target = self
		HelpItem.target = self
		AboutItem.target = self
		QuitItem.target = self
		
		SnapItem.setShortcut(for: .ToggleSnap)
		
		let Menu = NSMenu()
		Menu.addItem(SnapItem)
		Menu.addItem(NSMenuItem.separator())
		Menu.addItem(PreferencesItem)
		Menu.addItem(HelpItem)
		Menu.addItem(AboutItem)
		Menu.addItem(QuitItem)
		StatusItem.menu = Menu
		
		self.AppDelegate.Windows.StatusBarMenu = Menu
		
		if let StatusBarButton = StatusItem.button
		{
			StatusBarButton.image = NSImage(named: "SwiftReaderLogo")
			StatusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
			StatusBarButton.image?.isTemplate = true
			StatusBarButton.target = self
		}
	}
	private var AppDelegate: AppDelegate!
	private var StatusBar: NSStatusBar
	private var StatusItem: NSStatusItem
	private var Menu: NSMenu!
	@State private var bWindowVisible: Bool
	
	@objc func PreferencesSelect(_ sender: Any)
	{
		if (AppDelegate != nil)
		{
			if (AppDelegate.Windows.PreferencesWindow == nil)
			{
				AppDelegate.Windows.PreferencesWindow = NSWindow()
				AppDelegate.Windows.PreferencesWindow!.isReleasedWhenClosed = false
				AppDelegate.Windows.PreferencesWindow!.setIsVisible(false)
				AppDelegate.Windows.PreferencesWindow!.styleMask.insert(.closable)
				AppDelegate.Windows.PreferencesWindow!.title = "SwiftReader Preferences"
			}
			AppDelegate.Windows.PreferencesWindow!.contentView = NSHostingView(rootView: PreferencesView())
			AppDelegate.Windows.PreferencesWindow!.setFrameOrigin(CGPoint(x: NSScreen.main!.frame.width / 2 - AppDelegate.Windows.PreferencesWindow!.frame.width / 2, y: NSScreen.main!.frame.height / 2 - AppDelegate.Windows.PreferencesWindow!.frame.height / 2));
			if (!AppDelegate.Windows.PreferencesWindow!.isVisible)
			{
				WindowHandler.OpenWindow(Window: AppDelegate.Windows.PreferencesWindow!)
			}
			AppDelegate.Windows.PreferencesWindow!.makeKeyAndOrderFront(self)
			NSApp.activate(ignoringOtherApps: true)
			
			// Close other windows
			if (AppDelegate.Windows.SnapWindow != nil && AppDelegate.Windows.SnapWindow!.isVisible)
			{
				AppDelegate.CloseSnapWindow(self)
			}
			if (AppDelegate.Windows.HelpWindow != nil && AppDelegate.Windows.HelpWindow!.isVisible)
			{
				WindowHandler.CloseWindow(Window: AppDelegate.Windows.HelpWindow!)
			}
		}
	}
	
	@objc func HelpSelect(_ sender: Any)
	{
		if (AppDelegate != nil)
		{
			if (AppDelegate.Windows.HelpWindow == nil)
			{
				AppDelegate.Windows.HelpWindow = NSWindow()
				AppDelegate.Windows.HelpWindow!.isReleasedWhenClosed = false
				AppDelegate.Windows.HelpWindow!.setIsVisible(false)
				AppDelegate.Windows.HelpWindow!.styleMask.insert(.closable)
				AppDelegate.Windows.HelpWindow!.title = "SwiftReader Help"
			}
			AppDelegate.Windows.HelpWindow!.contentView = NSHostingView(rootView: HelpView())
			AppDelegate.Windows.HelpWindow!.setFrameOrigin(CGPoint(x: NSScreen.main!.frame.width / 2 - AppDelegate.Windows.HelpWindow!.frame.width / 2, y: NSScreen.main!.frame.height / 2 - AppDelegate.Windows.HelpWindow!.frame.height / 2))
			if (!AppDelegate.Windows.HelpWindow!.isVisible)
			{
				WindowHandler.OpenWindow(Window: AppDelegate.Windows.HelpWindow!)
			}
			AppDelegate.Windows.HelpWindow!.makeKeyAndOrderFront(self)
			NSApp.activate(ignoringOtherApps: true)
			
			// Close other windows
			if (AppDelegate.Windows.SnapWindow != nil && AppDelegate.Windows.SnapWindow!.isVisible)
			{
				AppDelegate.CloseSnapWindow(self)
			}
			if (AppDelegate.Windows.PreferencesWindow != nil && AppDelegate.Windows.PreferencesWindow!.isVisible)
			{
				WindowHandler.CloseWindow(Window: AppDelegate.Windows.PreferencesWindow!)
			}
		}
	}
	
	@objc func AboutSelect(_ sender: Any)
	{
		if let url = URL(string: "https://github.com/roesslere/SwiftReader")
		{
		   NSWorkspace.shared.open(url)
		}
	}
	
	@objc func QuitSelect(_ sender: Any)
	{
		NSApplication.shared.terminate(self)
	}
}
