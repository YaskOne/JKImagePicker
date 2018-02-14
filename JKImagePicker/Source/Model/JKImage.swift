//
//  JKImage.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import JackFoundation
import iOSCommons

//TODO: - Use swift as it most !
public protocol JKImageRepresentable {
	var image : UIImage? { get }
	var format: JKImageFormat? { get set }
}

public class JKImage: JKImageRepresentable {
	public var sourceImage : CGImage
	public var frame: CGRect { get {
		if let format = self.format {
			let rect = sourceImage.frame
			let cropRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.width / format.ratio.ratio)//.fitting(rect: image.frame)
			return cropRect
		} else {
			return sourceImage.frame
		}
		}}
	public var center: CGPoint = CGPoint(x: 0.5, y: 0.5)
	public var scale: CGFloat = 1.0

	public var format: JKImageFormat?
	
	public init(_ image: CGImage, format: JKImageFormat? = nil) {
		self.sourceImage = image
		self.format = format
	}
	
	public var originalImage: UIImage {
		return UIImage(cgImage: sourceImage, scale: scale, orientation: UIImageOrientation.up)
	}
	
	public var image : UIImage? {
		//if let format = self.format {
			let ow = CGFloat(sourceImage.width)
			let oh = CGFloat(sourceImage.height)
			
			let outputRect = frame
			let w = outputRect.width
			let h = outputRect.height
			
			let offset = CGPoint(x: (ow - w)/2, y: (oh - h)/2)
			let drawRect = CGRect(x: -offset.x, y: -offset.y, width: ow, height: oh)
			UIGraphicsBeginImageContextWithOptions(outputRect.size, false, self.scale)
			let ctx = UIGraphicsGetCurrentContext()
			ctx?.scaleBy(x: 1, y: -1)
			ctx?.translateBy(x: 0, y: -h)
			ctx?.draw(sourceImage, in: drawRect)
		
			let outImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			return outImage ?? UIImage(cgImage: sourceImage, scale: scale, orientation: UIImageOrientation.up)
		//}
		//return UIImage(cgImage: sourceImage, scale: scale, orientation: UIImageOrientation.up)
	}
}

