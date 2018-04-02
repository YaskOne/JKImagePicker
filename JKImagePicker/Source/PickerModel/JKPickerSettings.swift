//
//  JKPickerSettings.swift
//  JackCamera
//
//  Created by Tristan Leblanc on 13/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import AVFoundation

public struct JKPickerSettings {
	public var orientationLock: Bool
	public var snapTime: CGFloat
	public var hasSplitFeature: Bool
    public var hasFreeSplit: Bool
	public var allowSoloSplit: Bool
    public var hasConfirmation: Bool
    public var hasGallery: Bool
    public var formatRatios: [JKImageFormatRatio]
	public var useDummyCamera: Bool
	public var dummyImage1: UIImage?
    public var dummyImage2: UIImage?
    public var startPosition: AVCaptureDevice.Position
    public var startFeature: PickerFeature

    public init(orientationLock: Bool, snapTime: CGFloat, hasSplitFeature: Bool, hasFreeSplit: Bool, formatRatios: [JKImageFormatRatio], hasConfirmation: Bool = false, allowSoloSplit: Bool = false, hasGallery: Bool = false, dummyImage1: UIImage? = nil, dummyImage2: UIImage? = nil, startPosition: AVCaptureDevice.Position = .back, startFeature: PickerFeature = .split) {
		self.orientationLock = orientationLock
		self.snapTime = snapTime
		self.hasSplitFeature = hasSplitFeature
		self.hasFreeSplit = hasFreeSplit
		self.formatRatios = formatRatios
        self.hasConfirmation = hasConfirmation
		self.allowSoloSplit = allowSoloSplit
        self.hasGallery = hasGallery
		self.useDummyCamera = dummyImage1 != nil
        self.startPosition = startPosition
        self.startFeature = startFeature
	}
	
	public static var `default` = JKPickerSettings(orientationLock: true, snapTime: 0.3, hasSplitFeature: true, hasFreeSplit: true, formatRatios: JKImageFormatRatio.all)
	
	
}
