//
//  JKImagePickerViewController+Split.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

extension JKImagePickerViewController : JKFeatureViewControllerDelegate {
	
	func loadFeature(named name: String, animated: Bool = false) {

		if let vc = self.storyboard?.instantiateViewController(withIdentifier: name) as? JKFeatureViewController {
			vc.delegate = self
			view.insertSubview(vc.view, at: 1)
			addChildViewController(vc)
			self.featureVC = vc
			
			if animated {
				vc.view.alpha = 0
				UIView.animate(withDuration: 0.5) {
					vc.view.alpha = 1
				}
			}
			else {
				vc.view.alpha = 1
			}
		}

	}
	
	func removeFeature(animated: Bool = false) {
		if let vc = featureVC {
			if animated {
				UIView.animate(withDuration: 0.5, animations:{
					vc.view.alpha = 0
				}) { _ in
					vc.view.removeFromSuperview()
					vc.removeFromParentViewController()
				}
			}
			else {
				vc.view.removeFromSuperview()
				vc.removeFromParentViewController()
			}
		}
	}
	
	func featureDidLoad(_ featureVC: JKFeatureViewController) {
		self.featureVC = featureVC
		if  let vc = currentPickerController {
			featureVC.view.frame = vc.view.frame
		}
		featureVC.jkImage1 = image
	}
	
	func featureDidUnload(_ featureVC: JKFeatureViewController) {
		self.featureVC = nil
	}
}
