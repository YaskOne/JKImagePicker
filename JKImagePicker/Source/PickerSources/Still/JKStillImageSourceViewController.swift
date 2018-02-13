//
//  JKImagePreviewViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

class JKStillImageSourceViewController : JKSystemImageSourceViewController {
	
	var jkImage: JKImageRepresentable? { didSet {
			super.image = jkImage?.image
		}}
		
}
