//
//  JKSplitComposition.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import CoreGraphics

public class JKComposition: JKImageRepresentable {
	
	public var image: UIImage? { get {
		return nil
		}}

	public var _format: JKImageFormat?
	
	public var format: JKImageFormat? { get {
		return _format ?? image1?.format
		} set {
			_format = format
		}}

	public var image1: JKImage?
	public var image2: JKImage?
}

public class JKSplitComposition : JKComposition {
	public var angle: CGFloat = 0
	public var center: CGPoint = CGPoint(x: 0.5, y: 0.5)

	public override var image: UIImage? { get {
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
