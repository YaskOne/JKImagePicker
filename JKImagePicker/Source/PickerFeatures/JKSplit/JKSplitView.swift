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

struct JKSplitSettings {
	var angle: CGFloat = 0
	var center: CGPoint = CGPoint(x:0.5, y:0.5)
	
	init(angle: CGFloat = 0) {
		self.angle = angle
		self.center = CGPoint(x: 0.5, y:0.5)
	}

	init(angle: CGFloat = 0, center: CGPoint) {
		self.angle = angle
		self.center = CGPoint(x: 0.5, y:0.5)
	}
}

class JKSplitView: UIView {

	static let bigRect = CGRect(x:0, y:0, width: 10000, height: 10000)

	var settings: JKSplitSettings = JKSplitSettings()
	
	//MARK: - Images
	var image1:UIImage?
	var image2:UIImage?
	var swapped: Bool = false
	
	var getFirstImage: UIImage? {
		get {
			return swapped ? image2 : image1
		}
	}
	
	var getSecondImage: UIImage? {
		get {
			return swapped ? image1 : image2
		}
	}
	
	var gotOneImage: Bool { get {return image1 != nil || image2 != nil}}
	
	//MARK: - Overlay
	
	var overlayVisibility:(Bool,Bool) = (false,false)
	var overlayColors:(UIColor,UIColor) = (UIColor.green, UIColor.red)
	var overlayAlpha:(CGFloat,CGFloat) = (0.4,0.4)
	
	//MARK: - Line
	
	var showSplitLine:Bool = false
	
	//MARK: - Path
	
	var clipPath: CGPath { get { return clipPath() }}
	
	func clipPath(lineOnly: Bool = false, invert:  Bool = false) -> CGPath {
		return splittedRectPath(bounds, angle: settings.angle, center: settings.center, lineOnly: lineOnly, invert: invert)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.setNeedsDisplay()
	}
	
	override func draw(_ rect: CGRect) {
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
	
	func drawImages(context: CGContext) {
		drawImage(getFirstImage?.cgImage, clipPath: clipPath(), overlayIfNil: !gotOneImage && !swapped, context: context)
		drawImage(getSecondImage?.cgImage, clipPath: clipPath(invert: true), overlayIfNil: !gotOneImage && swapped, context: context)
	}
	
	func drawImage(_ image: CGImage?, clipPath: CGPath?, overlayIfNil: Bool = true, context: CGContext) {
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
			context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
			context.fill(bounds)
		}
		
		context.restoreGState()
	}
	
	func drawOverlays(context: CGContext) {
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
	
	func strokeSplitLine(context: CGContext) {
		context.saveGState()

		let clip = clipPath(lineOnly: true)
		context.addPath(clip)
		context.setStrokeColor(UIColor.white.cgColor)
		context.setLineWidth(4)
		context.strokePath()
		
		context.restoreGState()
	}

}


