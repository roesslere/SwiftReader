//
//  PreferencesView.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 9/22/21.
//

import SwiftUI
import AppKit
import KeyboardShortcuts
import Combine
import LaunchAtLogin

struct PreferencesView: View {
	init()
	{
		bLaunchAtLogin = UserPreferences.g_UserPreferences().bool(forKey: "bLaunchAtLogin")
		bViewRecognizedText = UserPreferences.g_UserPreferences().bool(forKey: "bViewRecognizedText")
		TextRecognitionLevel = UserPreferences.g_UserPreferences().object(forKey: "TextRecognitionLevel") as! Int
		UIColor1 = UserPreferences.g_UserPreferences().object(forKey: "UIColor1") as! String
		UIColor2 = UserPreferences.g_UserPreferences().object(forKey: "UIColor2") as! String
		
		TextRecognitionLevels = ["Accurate", "Fast"]
	}
	@State private var bLaunchAtLogin: Bool
	@State private var bViewRecognizedText: Bool
	@State private var TextRecognitionLevel: Int
	@State private var UIColor1: String
	@State private var UIColor2: String
	private let TextRecognitionLevels: Array<String>
	
	var body: some View {
		VStack {
			Image(nsImage: NSImage(imageLiteralResourceName: "SwiftReaderLogo"))
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 100, height: 100, alignment: .center)
				.padding(.top, 10)
			HStack {
				Text("Toggle Snap: ")
				KeyboardShortcuts.Recorder(for: .ToggleSnap)
			}
			.padding(.top, 20)
			
			Spacer()
			
			Divider()
				.padding(.horizontal, 10)
				.padding(.vertical, 10)
			
			HStack {
				Text("Launch at Login: ")
					.padding(.horizontal, 10)
				Spacer()
				Toggle("", isOn: $bLaunchAtLogin)
					.onChange(of: bLaunchAtLogin) { Value in
						UserPreferences.g_UserPreferences().setValue(Value, forKey: "bLaunchAtLogin")
						LaunchAtLogin.isEnabled = Value
					}
					.padding(.horizontal, 10)
			}
			
			/*
			HStack {
				Text("View Recognized Text (beta):")
					.padding(.horizontal, 10)
				Spacer()
				Toggle("", isOn: $ViewRecognizedText)
					.onChange(of: ViewRecognizedText) { Value in
						UserPreferences.g_UserPreferences().setValue(Value, forKey: "bViewRecognizedText")
					}
					.padding(.horizontal, 10)
			}
			*/

			HStack {
				Text("Text Recognition Level:")
					.padding(.horizontal, 10)
				Spacer()
				Picker("", selection: $TextRecognitionLevel) {
					ForEach(0..<TextRecognitionLevels.count) { Index in
						Text("\(TextRecognitionLevels[Index])")
					}
					.onChange(of: TextRecognitionLevel) { Value in
						UserPreferences.g_UserPreferences().setValue(Value, forKey: "TextRecognitionLevel")
					}
				}
				.frame(width: 100, height: .none, alignment: .center)
				.padding(.horizontal, 10)
			}
			
			HStack {
				Text("Primary Color:")
					.padding(.horizontal, 10)
				Spacer()
				TextField("", text: $UIColor1)
					.onChange(of: UIColor1, perform: { Value in
						UserPreferences.g_UserPreferences().setValue(Value, forKey: "UIColor1")
					})
					.frame(width: 90, height: .none, alignment: .center)
					.padding(.horizontal, 10)
			}
			HStack {
				Text("Secondary Color:")
					.padding(.horizontal, 10)
				Spacer()
				TextField("", text: $UIColor2)
					.onChange(of: UIColor2, perform: { Value in
						UserPreferences.g_UserPreferences().setValue(Value, forKey: "UIColor2")
					})
					.frame(width: 90, height: .none, alignment: .center)
					.padding(.horizontal, 10)
			}
			.padding(.bottom, 20)
		}
		.frame(width: 300, height: 450, alignment: .center)
		.cornerRadius(10.0)
		.background(Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.4).blur(radius: 3.0))
	}
}

struct PreferencesView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			PreferencesView()
		}
	}
}
