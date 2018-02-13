//
//  JKImagePicker.swift
//  JKImagePicker
//
//  Created by Tristan Leblanc on 13/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import Foundation

public struct JKImagePicker {
	public static let bundle = Bundle(identifier: "Jack-World.JKImagePicker")
	public static let storyboard = UIStoryboard(name: "JKImagePicker", bundle: JKImagePicker.bundle)
	
	public static func open(over viewController: UIViewController?, delegate: JKImagePickerDelegate, settings: JKPickerSettings? = nil) -> JKImagePickerViewController? {
		guard let nav = JKImagePicker.storyboard.instantiateInitialViewController() as? UINavigationController,
			let picker = nav.topViewController as? JKImagePickerViewController else {
				return nil
		}
		DispatchQueue.main.async {
			picker.delegate = delegate
			if let settings = settings {
				picker.settings = settings
			}
			nav.isNavigationBarHidden = true
			viewController?.present(nav, animated: true, completion: nil)
		}
		return picker
	}
	
}
