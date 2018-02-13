//
//  JKImagePickerSourceViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 05/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public protocol JKImagePickerSourceDelegate {
	
	/// picturaAvailable
	///
	/// Called when the image is ready to be used
	
	func pictureAvailable(_ image: UIImage)
	
	/// commandButtonTapped
	///
	/// Called when a command is not handled by the cameraViewController
	
	func commandButtonTapped(command: JKCameraCommand)
	
	/// stateChanged
	///
	/// Called when state of the picker changes
	/// So the delegate can update interface
	
	func stateChanged()
	
	/// enabledStateChanged
	///
	/// Called when the enabled value of the picker changes
	/// So the delegate can update interface
	
	func enabledStateChanged(_ enabled: Bool)
	
	func iconForControlItem(_ item:JKCameraControlItem) -> String

}

public class JKImagePickerSourceViewController : JKOrientatedViewController, JKPickerButtonsDelegate {
	
	
	public var delegate: JKImagePickerSourceDelegate?

	public var isEnabled: Bool = true { didSet {
		delegate?.enabledStateChanged(isEnabled)
		}}
	
	//MARK: - State change
	
	public func stateChanged() {
		delegate?.stateChanged()
	}
	
	public var ratio: CGFloat = 1 { didSet {
		guard let sv = view.superview else { return }
		var height = sv.bounds.width / ratio
		var width = sv.bounds.width
		
		if height > sv.bounds.height {
			let scaleDown = sv.bounds.height / height
			height *= scaleDown
			width *= scaleDown
		}
		
		let topOffset = (sv.bounds.height - height) / 2
		let leftOffset = (sv.bounds.width - width) / 2

		UIView.animate(withDuration: 0.3) {
			self.view.frame = CGRect.init(x: leftOffset, y: topOffset, width: width, height: height)
		}
		}}

    //MARK: - Orientation
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    public override var shouldAutorotate: Bool { get {
        return false
        }}

    @objc override public  func orientationChanged(notif: Notification) {
		super.orientationChanged(notif: notif)
	}

	//MARK: JKPickerButtonsDelegate
	
	public var controls : [JKCameraControlItem] { get {
		guard let featureControls = self.featureControls, !featureControls.isEmpty else {
			return availableControls
		}
		
		var ctrls = [JKCameraControlItem]()
		
		var featureIndex = 0
		
		for i in 0...6 {
			let control = availableControls[i]
			if control == .pad && featureIndex < featureControls.count {
				ctrls.append(featureControls[featureIndex])
				featureIndex += 1
			}
			else {
				ctrls.append(control)
			}
		}
		
		return ctrls
	}}
	
	public var availableControls: [JKCameraControlItem] { get {
		return [.pad,.pad,.pad,.pad,.pad,.pad,.close]
		}}
	
	public var featureControls:  [JKCameraControlItem]?
	
	public func commandButtonTapped(command: JKCameraCommand) {
		switch command {
		default:
			delegate?.commandButtonTapped(command: command)
			break
		}
	}

	public func iconForControlItem(_ item:JKCameraControlItem) -> String {
		if let icon = delegate?.iconForControlItem(item) {
			return icon
		}
		return item.defaultIcon
	}

}
