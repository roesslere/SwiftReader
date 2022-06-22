//
//  UIHelpers.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 6/11/22.
//

import Foundation
import SwiftUI

extension Path
{
	func StrokeFill(Color: Color, Stroke: StrokeStyle) -> some View
	{
		self
			.stroke(Color, style: Stroke)
			.background(self.fill(Color))
	}
}

// Luca Torella; https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
extension NSColor
{
	convenience init(HexString: String)
	{
		let Hex = HexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var Int = UInt64()
		Scanner(string: Hex).scanHexInt64(&Int)
		let A, R, G, B: UInt64
		switch Hex.count {
			case 3:
				(A, R, G, B) = (255, (Int >> 8) * 17, (Int >> 4 & 0xF) * 17, (Int & 0xF) * 17)
			case 6:
				(A, R, G, B) = (255, Int >> 16, Int >> 8 & 0xFF, Int & 0xFF)
			case 8:
				(A, R, G, B) = (Int >> 24, Int >> 16 & 0xFF, Int >> 8 & 0xFF, Int & 0xFF)
			default:
				(A, R, G, B) = (255, 255, 255, 255)
		}
		self.init(red: CGFloat(R) / 255, green: CGFloat(G) / 255, blue: CGFloat(B) / 255, alpha: CGFloat(A) / 255)
	}
}
