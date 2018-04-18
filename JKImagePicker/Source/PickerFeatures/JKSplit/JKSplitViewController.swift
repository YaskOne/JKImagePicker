//
//  ViewController.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 01/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

public enum JKSplitControl: Int {
	case inviteFriendsControlTag = 1
}

public class JKSplitViewController: JKFeatureViewController {
	
	@IBOutlet public var splitView: JKSplitView!

	@IBOutlet public var inviteFriendsToCompleteButton: UIButton?
	
    @IBOutlet weak var touchAngleControl: JKCenterAngleControlView!

	var allowSoloSplit:Bool = false
	
	public var allowsInviteFriends: Bool = true { didSet {
		updateInterface()
		}}
	
	public var allowsChangeAngle: Bool = true { didSet {
		updateInterface()
		}}
	
    //TODO: Fully replace UIImage by JKImages to allow repositionning
	public var jkImage2: JKImage?
	{
		didSet {
			image2 = jkImage2?.image
		}
	}

	override public var jkImage1: JKImage? {
		didSet {
			image1 = jkImage1?.image
		}
	}
	
	var splitFeatureView: JKSplitFeatureView? { return view as? JKSplitFeatureView }
	
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
		updateInterface()
		}}
	
	public var image2: UIImage? { didSet {
		splitView.image2 = image2
		splitView.setNeedsDisplay()
		updateInterface()
		}}
	
	//MARK: - Lifecycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		modeIndex = (modes.index{$0 == .vertical}) ?? 0
		self.view.clipsToBounds = true
		
		if let splitFeatureView = self.splitFeatureView, let inviteButton = self.inviteFriendsToCompleteButton {
			splitFeatureView.addInteractiveView(inviteButton)
		}
	}
	
	override public func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateInterface()
	}

	//MARK: - Update
	
	public func updateInterface() {
		inviteFriendsToCompleteButton?.layer.cornerRadius = 4
		inviteFriendsToCompleteButton?.isHidden = !(allowsInviteFriends && (image1 != nil && image2 == nil)) || !allowSoloSplit
	}
	
	public func updateSplit() {
		let color = splitView.settings.overlayColor
		var settings = mode.settingsForFrame(frame: self.view.frame)
		settings.angle += swapped ? CGFloat.pi : 0
		settings.overlayColor = color	
		splitView?.settings = settings
		modeButton?.setTitle(mode.label, for: .normal)
		splitView.setNeedsDisplay()
	}
	
	//MARK: - JKImagePicker Controls
	
	public override var controlItems: [JKCameraControlItem]? { get {
		return allowsChangeAngle ? [.split] : []
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
		if !allowsChangeAngle {
			return
		}
		var idx = modeIndex + 1
		if idx >= modes.count {
			idx = 0
			swapped = !swapped
		}
		modeIndex = idx
	}
	
	@IBAction func swapTapped() {
		if !allowsChangeAngle {
			return
		}
		swapped = !swapped
		updateSplit()
	}
	
	@IBAction func inviteFriendsTapped() {
		guard let button = inviteFriendsToCompleteButton else { return }
		delegate?.featureControlTapped(self, controlTag: button.tag)
	}
}
