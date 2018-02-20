//
//  JKSplitFeatureView.swift
//  JKImagePicker
//
//  Created by Tristan Leblanc on 20/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

class JKSplitFeatureView : UIView {
	
	var interactiveViews = [UIView]()
	
	public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		for view in interactiveViews {
			if view.frame.contains(point) && !view.isHidden {
				return true
			}
		}
		return false
	}
	
	func addInteractiveView(_ view: UIView) {
		interactiveViews.append(view)
	}
	
}
