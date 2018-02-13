//
//  JKPreviewViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public class JKSystemImageSourceViewController: JKImagePickerSourceViewController {

	@IBOutlet public var imageView: UIImageView?

	public var image: UIImage? {
		set {
            imageView?.image = newValue
		}
		get {
			return imageView?.image
		}
	}

	public override var availableControls: [JKCameraControlItem] { get {
		return [.camera,.gallery,.pad,.pad,.pad,.pad,.close]
		}}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		imageView?.frame = view.bounds
	}
}
