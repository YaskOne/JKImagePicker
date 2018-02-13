//
//  JKFeatureViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

protocol JKFeatureViewControllerDelegate {
	func featureDidLoad(_ featureVC: JKFeatureViewController)
	func featureDidUnload(_ featureVC: JKFeatureViewController)
}

protocol JKFeatureViewControllerProtocol {
	var controlItems:[JKCameraControlItem]? { get }
}

class JKFeatureViewController: UIViewController {

	var delegate: JKFeatureViewControllerDelegate?
	
	// A feature has at least one image
	var jkImage1: JKImage?


	override func viewDidLoad() {
		super.viewDidLoad()
		delegate?.featureDidLoad(self)
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if parent == nil {
			delegate?.featureDidUnload(self)
		}
	}

	var controlItems: [JKCameraControlItem]? {
		return nil
	}
	
	func commandButtonTapped(command: JKCameraCommand) {
	}

	func iconForControlItem(_ item:JKCameraControlItem) -> String? {
		return item.defaultIcon
	}
	
}
