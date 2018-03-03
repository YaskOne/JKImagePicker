//
//  JKPickerSettings.swift
//  JackCamera
//
//  Created by Tristan Leblanc on 13/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public struct JKPickerSettings {
	public var orientationLock: Bool
	public var snapTime: CGFloat
	public var hasSplitFeature: Bool
    public var hasFreeSplit: Bool
    public var hasConfirmation: Bool
    public var hasGallery: Bool
    public var formatRatios: [JKImageFormatRatio]
    public var lockOrientation: Bool
	
    public init(orientationLock: Bool, snapTime: CGFloat, hasSplitFeature: Bool, hasFreeSplit: Bool, formatRatios: [JKImageFormatRatio], hasConfirmation: Bool = false, hasGallery: Bool = false, lockOrientation: Bool = true) {
		self.orientationLock = orientationLock
		self.snapTime = snapTime
		self.hasSplitFeature = hasSplitFeature
		self.hasFreeSplit = hasFreeSplit
		self.formatRatios = formatRatios
        self.hasConfirmation = hasConfirmation
        self.hasGallery = hasGallery
        self.lockOrientation = lockOrientation
	}
	
	public static var `default` = JKPickerSettings(orientationLock: false, snapTime: 0.3, hasSplitFeature: true, hasFreeSplit: true, formatRatios: JKImageFormatRatio.all)
	
	
}