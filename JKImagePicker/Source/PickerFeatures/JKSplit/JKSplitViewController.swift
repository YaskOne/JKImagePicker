//
//  ViewController.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 01/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

public class JKSplitViewController: JKFeatureViewController {

	@IBOutlet public var splitView: JKSplitView!

    @IBOutlet weak var touchAngleControl: JKCenterAngleControlView!

    //TODO: Fully replace UIImage by JKImages to allow repositionning
	public var jkImage2: JKImage?

	public var modeButton: UIButton?
	
	public var mode: JKSplitMode = JKSplitMode.horizontal { didSet {
		updateSplit()
		}}
	
	public var modes: [JKSplitMode] = [.horizontal,.diagonalRight,.vertical,.diagonalLeft]
	
	public var modeIndex = 0 { didSet {
		mode = modes[modeIndex]
		}}
	
	public var swapped: Bool = false
	
	public var image: UIImage? { didSet {
		if image1 == nil {
			image1 = image
		}
		else {
			image2 = image
		}
		}}
	
	public var image1: UIImage? { didSet {
		splitView.image1 = image1
		splitView.setNeedsDisplay()
		}}
	
	public var image2: UIImage? { didSet {
		splitView.image2 = image2
		splitView.setNeedsDisplay()
		}}
	
	public func updateSplit() {
		var settings = mode.settingsForFrame(frame: self.view.frame)
		settings.angle += swapped ? CGFloat.pi : 0
		splitView?.settings = settings
		modeButton?.setTitle(mode.label, for: .normal)
		splitView.setNeedsDisplay()
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		modeIndex = (modes.index{$0 == .vertical}) ?? 0
		self.view.clipsToBounds = true
	}

	public override var controlItems: [JKCameraControlItem]? { get {
		return [.split]
		}}
	
	public override func commandButtonTapped(command: JKCameraCommand) {
		switch command {
		case JKCameraControlItem.split.rawValue:
			nextModeTapped()
		default:
			break
		}
	}

	public override func iconForControlItem(_ item:JKCameraControlItem) -> String?
	{
		if item == JKCameraControlItem.split {
			return mode.icon
		}
		return item.defaultIcon
	}
	
	public override func viewDidLayoutSubviews() {
		splitView?.frame = view.bounds
	}
}

public extension JKSplitViewController {
	
	@IBAction func nextModeTapped() {
		var idx = modeIndex + 1
		if idx >= modes.count {
			idx = 0
			swapped = !swapped
		}
		modeIndex = idx
	}
	
	@IBAction func swapTapped() {
		swapped = !swapped
		updateSplit()
	}
	
}
