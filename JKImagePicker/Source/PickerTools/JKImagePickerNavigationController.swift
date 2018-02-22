//
//  JKImagePickerNavigationController.swift
//  JKImagePicker
//
//  Created by Arthur Ngo Van on 14/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import Foundation

public class JKImagePickerNavigationController: UINavigationController {
	
	// For debugging purpose
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
		super.dismiss(animated: flag, completion: completion)
	}
	
    override public var shouldAutorotate: Bool {
        get {
            return false
        }
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    deinit {
        
    }
    
}
