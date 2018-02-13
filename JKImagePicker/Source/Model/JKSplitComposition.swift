//
//  JKSplitComposition.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import CoreGraphics

class JKComposition: JKImageRepresentable {
	
	var image: UIImage? { get {
		return nil
		}}

	var _format: JKImageFormat?
	
	var format: JKImageFormat? { get {
		return _format ?? image1?.format
		} set {
			_format = format
		}}

	var image1: JKImage?
	var image2: JKImage?
}

class JKSplitComposition : JKComposition {
	var angle: CGFloat = 0
	var center: CGPoint = CGPoint(x: 0.5, y: 0.5)

	override var image: UIImage? { get {
		guard let image1 = self.image1 else { return nil }
		let splitView = JKSplitView(frame: image1.frame)
		splitView.settings = JKSplitSettings.init(angle: angle,center: center)
		splitView.image1 = image1.image
		splitView.image2 = image2?.image
		splitView.setNeedsDisplay()
		let output = splitView.snapshot
		return output
		}}

	init(angle: CGFloat, center: CGPoint) {
		super.init()
		self.angle = angle
		self.center = center
	}
	

}
