//
//  JKOrientatedViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 11/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public class JKOrientatedViewController: UIViewController {

	public var orientation: UIDeviceOrientation = UIDevice.current.orientation { didSet {
		if let t = transform {
			updateOrientation(transform: t)
		}
		}}

	public override func viewDidLoad() {
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
	}

	@objc public func orientationChanged(notif: Notification) {
		let orientation = UIDevice.current.orientation
		switch orientation {
		case .portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight:
			self.orientation = orientation
		default:
			break
		}
	}
	
	public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	public override var shouldAutorotate: Bool { get {
		return false
		}}

	
	public func updateOrientation(transform t: CGAffineTransform) {
		// Override 
	}
	
	public var transform: CGAffineTransform? { get {
		let t = JKImagePickerUtils.orientationToTransform(orientation)
		return t
		}}

}
