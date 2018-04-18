//
//  JKImageFormatHelper.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 08/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public enum JKImageFormatOrientation {
	case portrait
	case landscape
	
	public var label: String { get {
		switch self {
		case .portrait:
			return "Portrait"
		case .landscape:
			return "Landscape"
		}
		}}
}

public enum JKImageFormatRatio {
	case fullFrame		// depends on camera capabilities
	case fullScreen		// depends on screen capabilities
	case standard
	case square
	case _16_9
	case cinemascope	// 2.35 : 1
	case golden 		// (1 + √5) / 2 = 1.618
	
	public static var all: [JKImageFormatRatio] { get {
		return [.fullFrame, .fullScreen, .standard, .square, ._16_9, .cinemascope, .golden]
		}}
	
	public var label: String { get {
		switch self {
		case .fullFrame:
			return "Full Frame"
		case .fullScreen:
			return "Full Screen"
		case .standard:
			return "Photo [3/4]"
		case .square:
			return "Square"
		case ._16_9:
			return "[16/9]"
		case .cinemascope:
			return "Cinemascope [2.35 : 1]"
		case .golden:
			return "Golden [(1 + √5) / 2]"
		}
		}}
	
	public var ratio: CGFloat { get {
		switch self {
		case .fullFrame:
			return JKImageFormatRatio.cameraFrame.size.width / JKImageFormatRatio.cameraFrame.size.height
		case .fullScreen:
			return JKImageFormatRatio.screenFrame.size.width / JKImageFormatRatio.screenFrame.size.height
		case .standard:
			return 3 / 4
		case .square:
			return 1
		case ._16_9:
			return 16 / 9
		case .cinemascope:
			return 2.35
		case .golden:
			return 1.6180339887
		}
		}}
	
	public static var cameraFrame: CGRect = CGRect(x:0, y:0, width: 320, height: 640)
	public static var screenFrame: CGRect = CGRect(x:0, y:0, width: 320, height: 640)
	
}

public struct JKImageFormat {
	public var ratio: JKImageFormatRatio
	public var orientation: JKImageFormatOrientation
	
	public var label:String { get { return "\(ratio.label) - \(orientation.label)"}}
}

public class JKImageFormatHelper {
	
	public static let shared = JKImageFormatHelper()
	
	public static let changed = Notification.Name("imageFormatChanged")

	public static let key = "format"

	public var formats = { return JKImageFormatRatio.all }() {
		didSet {
			format = formats[0]
		}
	}
	public var format: JKImageFormatRatio = JKImageFormatRatio.fullFrame { didSet {
		NotificationCenter.default.post(name: JKImageFormatHelper.changed, object: nil, userInfo: [JKImageFormatHelper.key : format])
		}}
	
	public init(formats: [JKImageFormatRatio] = JKImageFormatRatio.all, format: JKImageFormatRatio? = nil) {
		self.formats = formats
		if let _ = (formats.index{$0==format}) {
			self.format = format!
		}
		else {
			self.format = formats[0]
		}
	}
	
	public func nextFormat() {
		var index = formats.index{$0==format} ?? 0
		index = (index + 1) % formats.count
		format = formats[index]
	}
}

extension CGRect {
	//return a null origin based rectangle by applying ratio and orientation to target rectangle
	func apply(format:JKImageFormat) -> CGRect {
		var newHeight = height
		var newWidth = width
		let ratio = format.ratio.ratio

		if format.orientation == .landscape {
			newWidth = self.height * ratio
		} else {
			newHeight = self.width * ratio
		}
		if format.orientation == .landscape {
			return CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
		}
		// rotate if portrait
		//return CGRect(x: 0, y: 0, width: newHeight, height: newWidth)
		return CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
	}
}
