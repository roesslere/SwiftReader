//
//  MenuView.swift
//  printr
//
//  Created by Ethan Roessler  on 9/3/21.
//

import SwiftUI
import AppKit

struct StatusBarView: View
{
	var body: some View
	{
		VStack(spacing: 0) {
			Text("printr")
				.padding()
				.font(.headline)
			Spacer()
				.padding(0)
			Divider()
				.padding(0)
			HStack() {
				Button("Snap", action: {})
					.padding()
				Button("Options", action: {})
					.padding()
				Button("Quit", action: {})
					.padding()
			}
		}
		.frame(width: 300, height: 400, alignment: .center)
		.background(BackgroundEmitterView().ignoresSafeArea())
	}
}

struct BackgroundEmitterView: NSViewRepresentable
{
	func makeNSView(context: Context) -> NSView
	{
		let View = NSView()
		
		let EmitterLayer = CAEmitterLayer()
		EmitterLayer.bounds = CGRect(x: 0, y: 0, width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height)
		EmitterLayer.emitterShape = .line
		EmitterLayer.emitterCells = CreateEmitterCells()
		EmitterLayer.emitterSize = CGSize(width: NSScreen.main!.frame.width, height: 1)
		EmitterLayer.emitterPosition = CGPoint(x: NSScreen.main!.frame.width / 2, y: 0)
		EmitterLayer.backgroundColor = NSColor.clear.cgColor
		
		View.layer = EmitterLayer
		
		return View
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context)
	{
		
	}
	
	func CreateEmitterCells()->[CAEmitterCell]
	{
		let Cell = CAEmitterCell()
		
		Cell.birthRate = 3
		Cell.lifetime = 7.0
		Cell.lifetimeRange = 0
		Cell.velocity = 200
		Cell.velocityRange = 50
		Cell.emissionLongitude = CGFloat.pi
		Cell.emissionRange = CGFloat.pi / 4
		Cell.spin = 2
		Cell.spinRange = 3
		Cell.scaleRange = 0.5
		Cell.scaleSpeed = -0.05
		Cell.contents = NSImage(systemSymbolName: "play.circle", accessibilityDescription: nil)
		
		return [Cell]
	}
}

struct StatusBarView_Preview : PreviewProvider
{
	static var previews: some View
	{
		StatusBarView()
		BackgroundEmitterView()
	}
}
