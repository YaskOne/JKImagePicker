//
//  JKFeatureViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public protocol JKFeatureViewControllerDelegate {
	func featureDidLoad(_ featureVC: JKFeatureViewController)
	func featureDidUnload(_ featureVC: JKFeatureViewController)
	
	func featureControlTapped(_ featureVC: JKFeatureViewController, controlTag: Int)
}

public protocol JKFeatureViewControllerProtocol {
	var controlItems:[JKCameraControlItem]? { get }
}

public class JKFeatureViewController: UIViewController {

	public var delegate: JKFeatureViewControllerDelegate?
	
	// A feature has at least one image
	public var jkImage1: JKImage?


	public override func viewDidLoad() {
		super.viewDidLoad()
		delegate?.featureDidLoad(self)
	}
	
	public override func didMove(toParentViewController parent: UIViewController?) {
		if parent == nil {
			delegate?.featureDidUnload(self)
		}
	}

	public var controlItems: [JKCameraControlItem]? {
		return nil
	}
	
	public func commandButtonTapped(command: JKCameraCommand) {
	}

	public func iconForControlItem(_ item:JKCameraControlItem) -> String? {
		return item.defaultIcon
	}
	
}
