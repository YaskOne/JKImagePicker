//
//  JKPreviewViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

class JKSystemImageSourceViewController: JKImagePickerSourceViewController {

	@IBOutlet var imageView: UIImageView?

	var image: UIImage? {
		set {
            imageView?.image = newValue
		}
		get {
			return imageView?.image
		}
	}

	override var availableControls: [JKCameraControlItem] { get {
		return [.camera,.gallery,.pad,.pad,.pad,.pad,.close]
		}}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		imageView?.frame = view.bounds
	}
}
