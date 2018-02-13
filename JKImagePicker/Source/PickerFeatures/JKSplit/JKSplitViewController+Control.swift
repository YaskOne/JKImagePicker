//
//  JKSplitView+Control.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

extension JKSplitViewController : JKCenterAngleControlViewDelegate {
	func centerDidChange(_ center: CGPoint) {
		JKSplitMode.freeSettings.center = CGPoint(x: center.x / splitView.frame.width, y: center.y / splitView.frame.height)
		self.mode = .free
		splitView.setNeedsDisplay()

	}
	
	func angleDidChange(_ angle: CGFloat) {
		JKSplitMode.freeSettings.angle = angle
		self.mode = .free
		splitView.setNeedsDisplay()
	}
	
	
}
