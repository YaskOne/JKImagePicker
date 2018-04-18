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
	var frame: CGRect { get set }
}

public class JKImage: JKImageRepresentable {
	
	public var sourceImage : CGImage
	
	public var frame: CGRect { get {
		if let format = self.format {
			let rect = sourceImage.frame
            //TO: Check
			let cropRect = rect.apply(format: format)
			return cropRect
		} else {
			return sourceImage.frame
		}
		}
		set {
			
		}
	}
	
	public var center: CGPoint = CGPoint(x: 0.5, y: 0.5)
	public var scale: CGFloat = 1.0

	public var format: JKImageFormat?
	
	public init(_ image: CGImage, format: JKImageFormat? = nil) {
		self.sourceImage = image
		self.format = format
		self.frame = CGRect.zero
	}
	
	public var originalImage: UIImage {
		return UIImage(cgImage: sourceImage, scale: scale, orientation: UIImageOrientation.up)
	}
	
	public var image : UIImage? {
		let sourceImageWidth = CGFloat(sourceImage.width)
		let sourceImageHeight = CGFloat(sourceImage.height)
	
		let outputRect = frame
		
		let outputWidth = outputRect.width
		let outputHeight = outputRect.height
		
		let offset = CGPoint(x: (sourceImageWidth - outputWidth)/2, y: (sourceImageHeight - outputHeight)/2)
		let drawRect = CGRect(x: -offset.x, y: -offset.y, width: sourceImageWidth, height: sourceImageHeight)
		UIGraphicsBeginImageContextWithOptions(outputRect.size, false, self.scale)
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.scaleBy(x: 1, y: -1)
		ctx?.translateBy(x: 0, y: -outputHeight)
		ctx?.draw(sourceImage, in: drawRect)
	
		let outImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return outImage ?? UIImage(cgImage: sourceImage, scale: scale, orientation: UIImageOrientation.up)
	}
}

