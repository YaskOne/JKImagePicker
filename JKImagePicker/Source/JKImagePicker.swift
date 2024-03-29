//
//  JKImagePicker.swift
//  JKImagePicker
//
//  Created by Tristan Leblanc on 13/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import Foundation
import Photos
import JackFoundation

public struct JKImagePicker {
	public static let bundle = Bundle(identifier: "Jack-World.JKImagePicker")
	public static let storyboard = UIStoryboard(name: "JKImagePicker", bundle: JKImagePicker.bundle)
	
	public static func open(over viewController: UIViewController?, delegate: JKImagePickerDelegate, settings: JKPickerSettings? = nil, info: JsonDict? = nil) -> JKImagePickerViewController? {
		guard let nav = JKImagePicker.storyboard.instantiateInitialViewController() as? UINavigationController,
			let picker = nav.topViewController as? JKImagePickerViewController else {
				return nil
		}
        
		DispatchQueue.main.async {
			if let settings = settings {
				picker.settings = settings
			}
			picker.delegate = delegate
			picker.userInfo = info
			let _ = picker.view
			nav.isNavigationBarHidden = true
			viewController?.present(nav, animated: true, completion: nil)
		}
		return picker
	}

    public static func checkGalleryAuthorization(error: (() -> Void)? = nil, success: @escaping() -> Void) {
        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
            switch status {
            case .denied:
                error?()
                return
            case .authorized:
                success()
                return
            default:
                error?()
                return
            }
        })
    }
	
	public static var hasFrontCamera: Bool {
		return AVCaptureDevice.default(.builtInWideAngleCamera,
									   for: AVMediaType.video,
									   position: .front) != nil
	}
	
	public static var hasBackCamera: Bool {
		return AVCaptureDevice.default(.builtInWideAngleCamera,
									   for: AVMediaType.video,
									   position: .back) != nil
	}
}
