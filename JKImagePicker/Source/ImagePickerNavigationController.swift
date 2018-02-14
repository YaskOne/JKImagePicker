//
//  FixedNavigationController.swift
//  JKImagePicker
//
//  Created by Arthur Ngo Van on 14/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import Foundation

class ImagePickerNavigationController: UINavigationController {
    
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
