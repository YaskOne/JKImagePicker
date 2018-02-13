//
//  JKImageFormatHelper.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 08/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

enum JKImageFormatOrientation {
	case portrait
	case landscape
	
	var label: String { get {
		switch self {
		case .portrait:
			return "Portrait"
		case .landscape:
			return "Landscape"
		}
		}}
}

enum JKImageFormatRatio {
	case fullFrame		// depends on camera capabilities
	case fullScreen		// depends on screen capabilities
	case standard
	case square
	case _16_9
	case cinemascope	// 2.35 : 1
	case golden 		// (1 + √5) / 2 = 1.618
	
	static var all: [JKImageFormatRatio] { get {
		return [.fullFrame, .fullScreen, .standard, .square, ._16_9, .cinemascope, .golden]
		}}
	
	var label: String { get {
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
	
	var ratio: CGFloat { get {
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
	
	static var cameraFrame: CGRect = CGRect(x:0, y:0, width: 320, height: 640)
	static var screenFrame: CGRect = CGRect(x:0, y:0, width: 320, height: 640)
	
}

struct JKImageFormat {
	var ratio: JKImageFormatRatio
	var orientation: JKImageFormatOrientation
	
	var label:String { get { return "\(ratio.label) - \(orientation.label)"}}
}

class JKImageFormatHelper {
	
	static let shared = JKImageFormatHelper()
	
	static let changed = Notification.Name("imageFormatChanged")

	static let key = "format"

	var formats = { return JKImageFormatRatio.all }() {
		didSet {
			format = formats[0]
		}
	}
	var format: JKImageFormatRatio = JKImageFormatRatio.fullFrame { didSet {
		NotificationCenter.default.post(name: JKImageFormatHelper.changed, object: nil, userInfo: [JKImageFormatHelper.key : format])
		}}
	
	init(formats: [JKImageFormatRatio] = JKImageFormatRatio.all, format: JKImageFormatRatio? = nil) {
		self.formats = formats
		if let _ = (formats.index{$0==format}) {
			self.format = format!
		}
		else {
			self.format = formats[0]
		}
	}
	
	func nextFormat() {
		var index = formats.index{$0==format} ?? 0
		index = (index + 1) % formats.count
		format = formats[index]
	}
}
