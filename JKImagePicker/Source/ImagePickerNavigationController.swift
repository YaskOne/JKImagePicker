//
//  FixedNavigationController.swift
//  JKImagePicker
//
//  Created by Arthur Ngo Van on 14/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import Foundation

class ImagePickerNavigationController: UINavigationController {
	
	// For debugging purpose
	override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		super.dismiss(animated: flag, completion: completion)
	}
	
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
}
