//
//  JKOrientatedViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 11/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

class JKOrientatedViewController: UIViewController {

	var orientation: UIDeviceOrientation = UIDevice.current.orientation { didSet {
		if let t = transform {
			updateOrientation(transform: t)
		}
		}}

	override func viewDidLoad() {
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
	}

	@objc func orientationChanged(notif: Notification) {
		let orientation = UIDevice.current.orientation
		switch orientation {
		case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
			self.orientation = orientation
		default:
			break
		}
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	override var shouldAutorotate: Bool { get {
		return false
		}}

	
	func updateOrientation(transform t: CGAffineTransform) {
		// Override 
	}
	
	var transform: CGAffineTransform? { get {
		let t = JKImagePickerUtils.orientationToTransform(orientation)
		return t
		}}

}
