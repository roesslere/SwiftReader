//
//  ContentView.swift
//  swiftreader
//
//  Created by Ethan Roessler  on 9/1/21.
//

import SwiftUI
import AppKit
import HotKey

// Collection of variables relating to the 'snap' process; refreshes views when changed.
class ObservableSnapRectVars: ObservableObject
{
	init()
	{
		StartPoint = CGPoint(x: 0.0, y: 0.0)
		CurrentPoint = CGPoint(x: 0.0, y: 0.0)
		bDidComplete = false
	}
	@Published public var StartPoint: CGPoint
	@Published public var CurrentPoint: CGPoint
	@Published public var bDidComplete: Bool
}

// Refreshes views when Layer is updated/changed.
class ObservableOverlayViewLayer: ObservableObject
{
	init()
	{
		Layer = nil
	}
	@Published public var Layer: CALayer?
}

struct OverlayViewRepresentable: NSViewRepresentable
{
	@Binding public var OverlayViewLayer: CALayer?
	
	func makeNSView(context: Context) -> some NSView
	{
		let View = NSView()
		View.layer = CALayer()
		View.layer!.delegate = context.coordinator
		
		return View
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context)
	{
		
		nsView.layer = OverlayViewLayer
	}
	
	func makeCoordinator() -> Coordinator
	{
		Coordinator(Layer: $OverlayViewLayer)
	}

	class Coordinator: NSObject, CALayerDelegate
	{
		@Binding private var Layer: CALayer?

		init(Layer: Binding<CALayer?>)
		{
			self._Layer = Layer
		}

		func layerWillDraw(_ layer: CALayer)
		{
			Layer = layer
		}
	}
}

struct SnapView: View
{
	init (SnapRect: ObservableSnapRectVars = ObservableSnapRectVars(), Foreground: Color = .clear, Background: Color = .clear, OverlayViewLayer: ObservableOverlayViewLayer = ObservableOverlayViewLayer(), BorderSize: UnsafeMutablePointer<CGFloat> = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1), BorderColor: Color = .clear, AppDelegate: AppDelegate?, ContentView: ContentView? = nil)
	{
		_SnapRect = StateObject(wrappedValue: SnapRect)
		_OverlayViewLayer = StateObject(wrappedValue: OverlayViewLayer)
		self.Foreground = Foreground
		self.Background = Background
		self.BorderSize = BorderSize
		self.BorderColor = BorderColor
		self.AppDelegate = AppDelegate
		self.ContentView = ContentView
	}
	
	@StateObject private var SnapRect: ObservableSnapRectVars
	@StateObject private var OverlayViewLayer: ObservableOverlayViewLayer
	private var Foreground: Color
	private var Background: Color
	private var BorderSize: UnsafeMutablePointer<CGFloat> // Saves resources since view is already being updated
	private var BorderColor: Color
	private var AppDelegate: AppDelegate?
	private var ContentView: ContentView?
	
	var body: some View
	{
		ZStack {
			
			let SnapWidth = abs(SnapRect.StartPoint.x - SnapRect.CurrentPoint.x)
			let SnapHeight = abs(SnapRect.StartPoint.y - SnapRect.CurrentPoint.y)
			let SnapX = (SnapRect.StartPoint.x + SnapRect.CurrentPoint.x) / 2.0
			let SnapY = (SnapRect.StartPoint.y + SnapRect.CurrentPoint.y) / 2.0
			
			Rectangle()
				.stroke(self.BorderColor, lineWidth: self.BorderSize.pointee)
				.background(self.Foreground)
				.padding(0)
				.frame(width: SnapWidth, height: SnapHeight, alignment: .center)
				.position(x: SnapX, y: SnapY)
				.onTapGesture(count: 2) {
					OCR.readText(withWidth: SnapWidth, height: SnapHeight, x: SnapX - SnapWidth / 2, y: SnapY - SnapHeight / 2 + NSApplication.shared.windows.first!.contentView!.safeAreaInsets.top, layer: &self.OverlayViewLayer.Layer, startObservation: nil, stopObservation: nil, completion: self.CompletionAnimation)
				}
		}
		.background(self.Background)
	}
	
	func StartObservationAnimation()
	{
		
	}
	
	func StopObservationAnimation()
	{
		
	}
	
	// Animation that is played after OCR sucessfully analyzes text
	func CompletionAnimation(OverlayLayer: Optional<AutoreleasingUnsafeMutablePointer<Optional<CALayer>>>, X: CGFloat, Y: CGFloat, Width: CGFloat, Height: CGFloat)
	{
		self.BorderSize.pointee = 0.0
		self.SnapRect.bDidComplete = true
		
		let ScreenCenter: NSPoint = CGPoint(x: NSScreen.main!.frame.width / 2.0, y: NSScreen.main!.frame.height / 2.0)
		let CheckmarkWidth: CGFloat = 125.0
		let CheckmarkHeight: CGFloat = 125.0
		let TextSize: CGFloat = 16.0
		let Spacer: CGFloat = 30.0
		
		let Color1: CGColor = NSColor(HexString: UserPreferences.g_UserPreferences().object(forKey: "UIColor1") as! String).cgColor
		let Color2: CGColor = NSColor(HexString: UserPreferences.g_UserPreferences().object(forKey: "UIColor2") as! String).cgColor
		
		let Frame = CALayer()
		Frame.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8).cgColor
		Frame.borderColor = Color1
		Frame.borderWidth = 2.0
		Frame.cornerRadius = 8.0
		Frame.bounds = CGRect(x: 0, y: 0, width: 450, height: 320)
		Frame.position = ScreenCenter
		
		let Path = CGMutablePath()
		Path.move(to: CGPoint(x: 0, y: CheckmarkHeight / 3.0))
		Path.addLine(to: CGPoint(x: CheckmarkWidth / 3.0, y: 0))
		Path.addLine(to: CGPoint(x: CheckmarkWidth, y: CheckmarkHeight))
		
		let CheckmarkShape2 = CAShapeLayer()
		CheckmarkShape2.bounds = CGRect(x: 0, y: 0, width: CheckmarkWidth, height: CheckmarkHeight)
		CheckmarkShape2.path = Path
		CheckmarkShape2.strokeColor = NSColor.white.cgColor
		CheckmarkShape2.fillColor = NSColor.clear.cgColor
		CheckmarkShape2.shadowPath = Path
		CheckmarkShape2.shadowColor = NSColor.red.cgColor
		CheckmarkShape2.shadowRadius = 5.0
		CheckmarkShape2.shadowOffset = CGSize(width: 1.0, height: 1.0)
		CheckmarkShape2.lineWidth = 25
		CheckmarkShape2.lineCap = .square
		CheckmarkShape2.lineJoin = .round
		CheckmarkShape2.position = CGPoint(x: ScreenCenter.x, y: ScreenCenter.y + Spacer / 2 + TextSize / 2)
		
		let CheckmarkShape = CAShapeLayer()
		CheckmarkShape.bounds = CGRect(x: -CheckmarkWidth * 0.75, y: -CheckmarkHeight * 0.75, width: CheckmarkWidth, height: CheckmarkHeight)
		CheckmarkShape.path = Path
		CheckmarkShape.strokeColor = .white
		CheckmarkShape.fillColor = NSColor.clear.cgColor
		CheckmarkShape.shadowPath = Path
		CheckmarkShape.lineWidth = 20
		CheckmarkShape.lineCap = .square
		CheckmarkShape.lineJoin = .round
		
		let CheckmarkAnimation = CABasicAnimation(keyPath: "strokeEnd")
		CheckmarkAnimation.fromValue =  0.0
		CheckmarkAnimation.toValue = 1.0
		CheckmarkAnimation.duration = 0.3
		CheckmarkAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		CheckmarkAnimation.isRemovedOnCompletion = false
		
		CheckmarkShape.add(CheckmarkAnimation, forKey: "CheckmarkAnimation")
		
		let Checkmark = CAGradientLayer()
		Checkmark.bounds = CGRect(x: 0, y: 0, width: CheckmarkWidth * 1.5, height: CheckmarkHeight * 1.5)
		Checkmark.position = CGPoint(x: ScreenCenter.x, y: ScreenCenter.y + Spacer / 2 + TextSize / 2)
		
		Checkmark.colors = [Color1, Color2]
		Checkmark.locations = [0.0, 1.0]
		Checkmark.mask = CheckmarkShape
		
		let TextLayer = CATextLayer()
		TextLayer.bounds = CGRect(x: 0, y: 0, width: 200, height: 100)
		TextLayer.position = CGPoint(x: ScreenCenter.x, y: ScreenCenter.y - CheckmarkHeight - Spacer / 2 + TextSize / 2)
		TextLayer.string = "Successfully Saved Text 👍"
		TextLayer.fontSize = TextSize
		TextLayer.alignmentMode = .center
		TextLayer.contentsScale = NSScreen.main!.backingScaleFactor
		
		let OpacityAnimation = CABasicAnimation(keyPath: "opacity")
		OpacityAnimation.fromValue = 0.0
		OpacityAnimation.toValue = 1.0
		OpacityAnimation.duration = 0.3
		OpacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		OpacityAnimation.isRemovedOnCompletion = false
		
		Frame.add(OpacityAnimation, forKey: "OpacityAnimation")
		TextLayer.add(OpacityAnimation, forKey: "OpacityAnimation")
		
		OverlayLayer?.pointee?.addSublayer(Frame)
		OverlayLayer?.pointee?.addSublayer(Checkmark)
		OverlayLayer?.pointee?.addSublayer(TextLayer)
		
		if (AppDelegate != nil)
		{
			AppDelegate!.SetSnapView(View: ContentView!)
			Timer.scheduledTimer(timeInterval: 0.66, target: AppDelegate!, selector: CGPreflightScreenCaptureAccess() ? #selector(AppDelegate!.CloseSnapWindow(_:)) : #selector(AppDelegate!.CloseSnapWindowAndShowPermissions(_:)), userInfo: nil, repeats: false)
		}
	}
}

struct TintViewRepresentable: NSViewRepresentable
{
	init (SnapRect: ObservableSnapRectVars)
	{
		_SnapRect = StateObject(wrappedValue: SnapRect)
	}
	@StateObject public var SnapRect: ObservableSnapRectVars
	
	func makeNSView(context: Context) -> some NSView
	{
		let View = NSView(frame: NSScreen.main!.frame)
		View.layer = CALayer()
		View.layer!.backgroundColor = UIStyle.colorTranslucentGrey().cgColor
		
		return View
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context)
	{
		let Width = abs(self.SnapRect.StartPoint.x - self.SnapRect.CurrentPoint.x)
		let Height = abs(self.SnapRect.StartPoint.y - self.SnapRect.CurrentPoint.y)
		let X = (self.SnapRect.StartPoint.x + self.SnapRect.CurrentPoint.x) / 2.0
		let Y = (self.SnapRect.StartPoint.y + self.SnapRect.CurrentPoint.y) / 2.0
		
		let MaskPath = CGMutablePath()
		MaskPath.addRect(nsView.bounds)
		MaskPath.addRect(CGRect(x: X - Width / 2.0, y: abs(Y - nsView.frame.height) - Height / 2.0, width: Width, height: Height))
		
		let Mask = CAShapeLayer()
		Mask.frame = nsView.bounds
		Mask.path = MaskPath
		Mask.fillRule = .evenOdd
		Mask.backgroundColor = .clear
		
		let Background = CALayer()
		Background.frame = nsView.bounds
		Background.backgroundColor = UIStyle.colorTranslucentGrey().cgColor
		Background.mask = Mask
		
		nsView.layer! = Background
		
		if (SnapRect.bDidComplete)
		{
			let MaskAnimation = CABasicAnimation(keyPath: "backgroundColor")
			MaskAnimation.fromValue = NSColor.clear.cgColor
			MaskAnimation.toValue = NSColor.black.cgColor
			MaskAnimation.duration = 0.3
			MaskAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
			MaskAnimation.fillMode = .forwards
			MaskAnimation.isRemovedOnCompletion = false
			
			Mask.add(MaskAnimation, forKey: "MaskAnimation")
		}
	}
}

struct ContentView: View
{
	init()
	{
		AppDelegate = nil
			
		BorderSize = UnsafeMutablePointer.allocate(capacity: 1)
		BorderSize.initialize(to: 2.0)
		
		SnapRect = ObservableSnapRectVars()
		OverlayViewLayer = ObservableOverlayViewLayer()
		bCreateStartPoint = true
	}
	private var AppDelegate: AppDelegate?
	private var BorderSize: UnsafeMutablePointer<CGFloat>
	@ObservedObject private var SnapRect: ObservableSnapRectVars
	@ObservedObject private var OverlayViewLayer: ObservableOverlayViewLayer
	@State private var bCreateStartPoint: Bool
	
	mutating func SetAppDelegate(AppDelegate: AppDelegate?)
	{
		self.AppDelegate = AppDelegate
	}
	
    var body: some View {

		ZStack() {
			TintViewRepresentable(SnapRect: SnapRect)
			ZStack() {
				VStack() {
					ZStack() {
						OverlayViewRepresentable(OverlayViewLayer: $OverlayViewLayer.Layer)
						
						SnapView(SnapRect: SnapRect, Foreground: Color(red: 0, green: 0, blue: 0, opacity: 0.01), // Must have opacity of 0.01 to maintain pointer interaction
								 Background: .clear, OverlayViewLayer: OverlayViewLayer, BorderSize: self.BorderSize, BorderColor: .gray, AppDelegate: AppDelegate!, ContentView: self)
					}
				}
				.background(Color.clear)
			}
		}
		.background(Color(UIStyle.colorClearTouchable()))
		.frame(width: NSScreen.main?.frame.width, height: NSScreen.main?.frame.height, alignment: .center)
		.contentShape(Rectangle())
		.gesture(DragGesture(minimumDistance: 1, coordinateSpace: CoordinateSpace.local)
					.onChanged { Value in
						self.OverlayViewLayer.Layer = nil
						if (self.bCreateStartPoint)
						{
							self.bCreateStartPoint = false
							self.SnapRect.StartPoint = Value.location
						}
						self.SnapRect.CurrentPoint = Value.location
					}
					.onEnded { Value in
						self.bCreateStartPoint = true
					}
		)
		.edgesIgnoringSafeArea(.top)
		
	}
	
	public func Reset()
	{
		self.bCreateStartPoint = true
		self.SnapRect.StartPoint = CGPoint(x: 0, y: 0)
		self.SnapRect.CurrentPoint = CGPoint(x: 0, y: 0)
		self.SnapRect.bDidComplete = false
		self.BorderSize.pointee = 2.0
		
		if (self.OverlayViewLayer.Layer != nil)
		{
			self.OverlayViewLayer.Layer!.sublayers?.forEach { $0.removeFromSuperlayer() }
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
    }
}
