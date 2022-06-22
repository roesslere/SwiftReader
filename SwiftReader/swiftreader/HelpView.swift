//
//  HelpView.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 2/20/22.
//

import SwiftUI
import AVKit
import MediaPlayer
import SwiftUIPager
import KeyboardShortcuts

struct PageData
{
	init(GifName: NSString, GifSize: CGFloat, CaptionText: Text, ShadowOpacity: Double = 0.0, ShadowRadius: CGFloat = 10, ShadowX: CGFloat = 0, ShadowY: CGFloat = 0)
	{
		GifView = GifViewRepresentable(Path: GifName, Size: GifSize)
		self.CaptionText = CaptionText
		self.ShadowOpacity = ShadowOpacity
		self.ShadowRadius = ShadowRadius
		self.ShadowX = ShadowX
		self.ShadowY = ShadowY
	}
	public var GifView: GifViewRepresentable
	public var CaptionText: Text
	public var ShadowOpacity: Double
	public var ShadowRadius: CGFloat
	public var ShadowX: CGFloat
	public var ShadowY: CGFloat
}

struct GifViewRepresentable: NSViewRepresentable
{
	init(Path: NSString, Size: CGFloat)
	{
		self.Path = Path
		self.Size = Size
		self.GifView = NSImageView()
	}
	@State var Path: NSString
	@State var Size: CGFloat
	@State var GifView: NSImageView
	
	func makeNSView(context: Context) -> some NSView
	{
		let ImageData = NSDataAsset(name: Path as NSDataAsset.Name)
		if (ImageData != nil)
		{
			let Image = NSImage(data: ImageData!.data)!
			let SizeScale = min(self.Size / Image.size.width, self.Size / Image.size.height)
			
			Image.size.width *= SizeScale
			Image.size.height *= SizeScale
			
			GifView.animates = false
			GifView.image = Image
		}
		
		return GifView
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context)
	{
		
	}
	
	func SetAnimated(Animated: Bool)
	{
		self.GifView.animates = Animated
	}
}

struct HelpView: View {
	init()
	{
		_Page = StateObject(wrappedValue: .first())
		CurrentPage = 0
		Data = Array(0..<3)
		
		Pages = [PageData(GifName: "SwiftReaderLogoAnimated",
						  GifSize: 300,
						  CaptionText: Text("Welcome to ") + Text("SwiftReader").bold() + Text(", an OCR reader!")),
				 PageData(GifName: "OCRSnapDemo",
						  GifSize: 550,
						  CaptionText: Text("To display the overlay, use the shortcut '") + Text("\(KeyboardShortcuts.Name.ToggleSnap.defaultShortcut?.description ?? "No keybind bound")").bold() + Text("' or click the SwiftReader icon and press ") + Text("Snap").bold() + Text(". You can exit this overlay by pressing the '") + Text("ESC").bold() + Text("' key."),
						  ShadowOpacity: 0.5),
				 PageData(GifName: "OCRTextDemo",
						  GifSize: 550,
						  CaptionText: Text("Drag over the desired area and double click the created rectangle. Captured text will be automatically copied to your clipboard!"),
						  ShadowOpacity: 0.3)]
	}
	@StateObject var Page: Page
	@State var CurrentPage: Int
	var Data: Array<Int>
	var Pages: Array<PageData>
	
	var body: some View {
		ZStack {
			Pager(page: Page, data: Data, id: \.self) {
				self.PageView($0)
					.frame(width: 700, height: 500, alignment: .center)
			}
			.onPageWillChange({(NewPage) in
				Pages[Page.index].GifView.SetAnimated(Animated: false)
				Pages[NewPage].GifView.SetAnimated(Animated: true)
			})
			.onAppear
			{
				Pages[Page.index].GifView.SetAnimated(Animated: true)
			}
			VStack {
				Spacer()
				PageIndicator(TotalPages: self.Data.count, Page: Page.index, ArrowSize: 20, CircleSize: 8, Padding: 5)
					.padding(.bottom, 20)
			}
		}
		.frame(width: 700, height: 500, alignment: .center)
	}
	
	func PageView(_ Page: Int) -> some View
	{
		HStack {
			VStack {
				Pages[Page].GifView
					.shadow(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: Pages[Page].ShadowOpacity), radius: Pages[Page].ShadowRadius, x: Pages[Page].ShadowX, y: Pages[Page].ShadowY)
				Spacer()
				Pages[Page].CaptionText
					.font(.custom("Helvetica", size: 22))
					.padding(.horizontal, 50)
					.padding(.bottom, 65)
			}
		}
		.background(Color(UIStyle.colorClearTouchable()))
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	func PageIndicator(TotalPages: Int, Page: Int, ArrowSize: CGFloat, CircleSize: CGFloat, Padding: CGFloat) -> some View
	{
		HStack {
			Path { Path in
				Path.move(to: CGPoint(x: ArrowSize, y: ArrowSize))
				Path.addLine(to: CGPoint(x: 0, y: ArrowSize / 2))
				Path.addLine(to: CGPoint(x: ArrowSize, y: 0))
				Path.closeSubpath()
			}
			.StrokeFill(Color: .white, Stroke: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
			.frame(width: ArrowSize, height: ArrowSize, alignment: .center)
			.padding(.horizontal, Padding)
			.onTapGesture {
				Pages[self.Page.index].GifView.SetAnimated(Animated: false)
				self.Page.update(.previous)
				Pages[self.Page.index].GifView.SetAnimated(Animated: true)
			}
			
			ForEach(0..<TotalPages) { i in
				let Opacity = i == Page ? 1.0 : 0.5
				Circle()
					.fill(Color.white)
					.frame(width: CircleSize, height: CircleSize, alignment: .center)
					.padding(.horizontal, Padding)
					.opacity(Opacity)
			}
			
			Path { Path in
				Path.move(to: CGPoint(x: 0, y: ArrowSize))
				Path.addLine(to: CGPoint(x: ArrowSize, y: ArrowSize / 2))
				Path.addLine(to: CGPoint(x: 0, y: 0))
				Path.closeSubpath()
			}
			.StrokeFill(Color: .white, Stroke: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
			.frame(width: ArrowSize, height: ArrowSize, alignment: .center)
			.padding(.horizontal, Padding)
			.onTapGesture {
				Pages[self.Page.index].GifView.SetAnimated(Animated: false)
				self.Page.update(.next)
				Pages[self.Page.index].GifView.SetAnimated(Animated: true)
			}
		}
		.padding(.all, 0)
	}
	
	func CloseView()
	{
		for i in 0..<Pages.count
		{
			Pages[i].GifView.SetAnimated(Animated: false)
		}
	}
}

struct HelpView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			HelpView()
		}
	}
}
