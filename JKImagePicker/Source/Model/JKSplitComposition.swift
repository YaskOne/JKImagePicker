//
//  JKSplitComposition.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import CoreGraphics
import JackFoundation

public class JKComposition: JKImageRepresentable {
	
	public var image: UIImage? { get {
		return nil
		}}
	
	private var _frame: CGRect?
	
	public var frame: CGRect { get {
		if let f = _frame {
			return f
		}
		
		var f = CGRect.zero
		if let img1 = image1 {
			f = img1.frame
		}
		else if let img2 = image2 {
			f = img2.frame
		}
		return f
		}
		set {
			_frame = newValue
		}
	}
	
	private var _format: JKImageFormat?
	
	public var format: JKImageFormat? { get {
		return _format ?? image1?.format
		} set {
			_format = format
		}}

	public var image1: JKImage?
	public var image2: JKImage?
	
	public func dictionary(image1UID: String, image2UID: String) -> JsonDict {
		let img1Dict: JsonDict = ["uid" : image1UID]
		let img2Dict: JsonDict = ["uid" : image2UID]
		let splitDict: JsonDict = ["image1": img1Dict, "image2": img2Dict]
		let featuresDict: JsonDict = ["base" : splitDict]
		let info: JsonDict = ["size": frame.size, "features" : featuresDict]
		
		return info
	}

}

public class JKSplitComposition : JKComposition {
	public var angle: CGFloat = 0
	public var center: CGPoint = CGPoint(x: 0.5, y: 0.5)

	override public func dictionary(image1UID: String, image2UID: String) -> JsonDict {
		let img1Dict: JsonDict = ["uid" : image1UID]
		let img2Dict: JsonDict = ["uid" : image2UID]
		let splitDict: JsonDict = ["angle" : angle, "center" : center, "image1": img1Dict, "image2": img2Dict]
		let featuresDict: JsonDict = ["split" : splitDict]
		let info: JsonDict = ["size": frame.size, "features" : featuresDict]
		
		return info
		}
	
	public override var image: UIImage? { get {
        guard let img1 = image1?.image?.cgImage, let img2 = image2?.image?.cgImage, let frame = image1?.frame else {
            return nil
        }
        return JKSplitView.generateSplitImage(image1: img1, image2: img2, angle: angle, center: center, frame: frame)
        }
    }

	
	init(angle: CGFloat, center: CGPoint) {
		super.init()
		self.angle = angle
		self.center = center
	}
	
	
}
