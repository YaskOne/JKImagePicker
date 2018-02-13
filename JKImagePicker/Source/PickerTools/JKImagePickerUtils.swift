//
//  JKImagePickerUtils.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 05/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public class JKImagePickerUtils {
	
	public static func orientationToAngle(_ orientation: UIDeviceOrientation) -> Double? {
		switch orientation {
		case .portrait:
			return 0
		case .portraitUpsideDown:
			return Double.pi
		case .landscapeLeft:
			return Double.pi / 2
		case .landscapeRight:
			return -Double.pi / 2
		default:
			return nil
		}
	}
	
	public static func orientationToTransform(_ orientation: UIDeviceOrientation) -> CGAffineTransform? {
		if let angle = JKImagePickerUtils.orientationToAngle(orientation) {
			return CGAffineTransform(rotationAngle: CGFloat(angle))
		}
		return nil
	}

}
