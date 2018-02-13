//
//  ViewController.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 01/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

class JKSplitViewController: JKFeatureViewController {

	@IBOutlet var splitView: JKSplitView!

	//TODO: Fully replace UIImage by JKImages to allow repositionning
	var jkImage2: JKImage?

	var modeButton: UIButton?
	
	var mode: JKSplitMode = JKSplitMode.horizontal { didSet {
			splitView?.settings = mode.settings
			modeButton?.setTitle(mode.label, for: .normal)
			splitView.setNeedsDisplay()
		}}
	
	var modes: [JKSplitMode] = [.vertical,.diagonalLeft,.horizontal,.diagonalRight]
	
	var modeIndex = 0 { didSet {
		mode = modes[modeIndex]
		}}
	
	var image: UIImage? { didSet {
		if image1 == nil {
			image1 = image
		}
		else {
			image2 = image
		}
		}}
	
	var image1: UIImage? { didSet {
		splitView.image1 = image1
		splitView.setNeedsDisplay()
		}}
	
	var image2: UIImage? { didSet {
		splitView.image2 = image2
		splitView.setNeedsDisplay()
		}}

	var swapped = false { didSet {
		splitView.swapped = swapped
		splitView.setNeedsDisplay()
		}}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		swapped = false
		modeIndex = JKSplitMode.vertical.rawValue
		self.view.clipsToBounds = true
	}

	override var controlItems: [JKCameraControlItem]? { get {
		return [.split,.swap]
		}}
	
	override func commandButtonTapped(command: JKCameraCommand) {
		switch command {
		case JKCameraControlItem.split.rawValue:
			nextModeTapped()
		case JKCameraControlItem.swap.rawValue:
			swapTapped()
		default:
			break
		}
	}

	override func iconForControlItem(_ item:JKCameraControlItem) -> String?
	{
		if item == JKCameraControlItem.split {
			return mode.icon
		}
		return item.defaultIcon
	}
	
	override func viewDidLayoutSubviews() {
		self.splitView?.frame = view.bounds
	}
}

extension JKSplitViewController {
	
	@IBAction func nextModeTapped() {
		var idx = modeIndex + 1
		if idx >= modes.count {
			swapped = !swapped
			idx = 0
		}
		modeIndex = idx
	}
	
	@IBAction func swapTapped() {
		swapped = !swapped
	}
	
}
