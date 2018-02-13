//
//  JKSplitView.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 01/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

import iOSCommons
import JackFoundation

public struct JKSplitSettings {
	public var angle: CGFloat = 0
	public var center: CGPoint = CGPoint(x:0.5, y:0.5)
	
	public init(angle: CGFloat = 0) {
		self.angle = angle
		self.center = CGPoint(x: 0.5, y:0.5)
	}

	public init(angle: CGFloat = 0, center: CGPoint) {
		self.angle = angle
		self.center = CGPoint(x: 0.5, y:0.5)
	}
}

public class JKSplitView: UIView {

	public static let bigRect = CGRect(x:0, y:0, width: 10000, height: 10000)

	public var settings: JKSplitSettings = JKSplitSettings()
	
	//MARK: - Images
	public var image1:UIImage?
	public var image2:UIImage?
	
	public var getFirstImage: UIImage? {
		get {
			return image1
		}
	}
	
	public var getSecondImage: UIImage? {
		get {
			return image2
		}
	}
	
	public var gotOneImage: Bool { get {return image1 != nil || image2 != nil}}
	
	//MARK: - Overlay
	
	public var overlayVisibility:(Bool,Bool) = (false,false)
	public var overlayColors:(UIColor,UIColor) = (UIColor.green, UIColor.red)
	public var overlayAlpha:(CGFloat,CGFloat) = (0.4,0.4)
	
	public var overlayOpacity: CGFloat = 0.8
	
	//MARK: - Line
	
	public var showSplitLine:Bool = false
	
	//MARK: - Path
	
	public var clipPath: CGPath { get { return clipPath() }}
	
	public func clipPath(lineOnly: Bool = false, invert:  Bool = false) -> CGPath {
		return splittedRectPath(bounds, angle: settings.angle, center: settings.center, lineOnly: lineOnly, invert: invert)
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		self.setNeedsDisplay()
	}
	
	public override func draw(_ rect: CGRect) {
		guard let ctx = UIGraphicsGetCurrentContext() else { return }
		ctx.saveGState()
		ctx.setFillColor(UIColor.clear.cgColor)
		ctx.clear(bounds)

		drawImages(context: ctx)
		
		if overlayVisibility.0 && overlayVisibility.1 {
			drawOverlays(context: ctx)
		}
		if showSplitLine {
			strokeSplitLine(context: ctx)
		}
	}
	
	public func drawImages(context: CGContext) {
		drawImage(getFirstImage?.cgImage, clipPath: clipPath(), overlayIfNil: false, context: context)
		drawImage(getSecondImage?.cgImage, clipPath: clipPath(invert: true), overlayIfNil: !gotOneImage , context: context)
	}
	
	public func drawImage(_ image: CGImage?, clipPath: CGPath?, overlayIfNil: Bool = true, context: CGContext) {
		context.saveGState()
		
		if let clip = clipPath {
			context.addPath(clip)
			context.clip()
		}
		
		context.scaleBy(x: 1, y: -1)
		context.translateBy(x: 0, y: -bounds.height)

		if 	let img = image {
			context.draw(img, in: img.frame.filling(rect: self.bounds))
			
		}
		else if overlayIfNil {
			context.setFillColor(UIColor.black.withAlphaComponent(overlayOpacity).cgColor)
			context.fill(bounds)
		}
		
		context.restoreGState()
	}
	
	public func drawOverlays(context: CGContext) {
		context.saveGState()
		
		let clip = clipPath
		context.addPath(clip)
		context.setFillColor(overlayColors.0.withAlphaComponent(overlayAlpha.0).cgColor)
		context.fillPath()
		
		let clip2 = clipPath(invert: true)
		context.addPath(clip2)
		context.setFillColor(overlayColors.1.withAlphaComponent(overlayAlpha.1).cgColor)
		context.fillPath()
		
		context.restoreGState()
	}
	
	public func strokeSplitLine(context: CGContext) {
		context.saveGState()

		let clip = clipPath(lineOnly: true)
		context.addPath(clip)
		context.setStrokeColor(UIColor.white.cgColor)
		context.setLineWidth(4)
		context.strokePath()
		
		context.restoreGState()
	}


}


