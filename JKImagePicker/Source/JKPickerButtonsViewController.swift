//
//  PickerControllsViewController.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 29/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public typealias JKCameraCommand = Int

public protocol JKPickerButtonsDelegate {
	
	var controls: [JKCameraControlItem] { get }

	var availableControls: [JKCameraControlItem] { get }
	
	func commandButtonTapped(command: JKCameraCommand)
	
	func iconForControlItem(_ item:JKCameraControlItem) -> String
}

public enum JKCameraControlItem: Int {
	case pad
	case flash
	case gallery
	case switchCam
	case camera
	case close
	
	case split
	case swap

	public var defaultIcon: String {
		switch self {
		case .pad:
			return ""
		case .flash:
			return JackImagePickerFont.icon_flash_off
		case .gallery:
			return JackImagePickerFont.icon_library
		case .split:
			return JackImagePickerFont.icon_split_vertical
		case .swap:
			return JackImagePickerFont.icon_split_swap
		case .switchCam:
			return JackImagePickerFont.icon_switch
		case .camera:
			return JackImagePickerFont.icon_camera
		case .close:
			return JackImagePickerFont.icon_cross
		}
	}
	
}

public class JKPickerButtonsViewController: JKOrientatedViewController {
    
	public var delegate: JKPickerButtonsDelegate? { didSet {
		reload()
		}}
	
	@IBOutlet public weak var stackView: UIStackView!
		
	@objc public func buttonTapped(sender: UIButton) {
		let command = sender.tag
		delegate?.commandButtonTapped(command: command)
	}
	
	public func reload() {
		for view in stackView.subviews {
			view.removeFromSuperview()
		}
		guard let items = delegate?.controls else { return }
		for item in items {
			let button = makeButton(for: item)
			stackView.addArrangedSubview(button)
		}
	}
	
	public func makeButton(for item:JKCameraControlItem) -> UIButton {
		let button = JKShadowButton(frame: frameForItem)
		
		if let font = UIFont(name: "jackfont", size: 30) {
			button.titleLabel?.font = font
		}

		let icon = delegate?.iconForControlItem(item)
		button.setTitle(icon, for: .normal)
        button.titleLabel?.textAlignment = .center
		
		button.titleLabel?.minimumScaleFactor = 0.5
		button.tag = item.rawValue
		button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
		return button
	}
	
	public var frameForItem: CGRect {
		return CGRect(x: 0, y: 0, width: view.bounds.height, height: view.bounds.height)
	}

	public override func updateOrientation(transform t: CGAffineTransform) {
		guard let views = self.stackView?.arrangedSubviews else { return }
		UIView.animate(withDuration: 0.3) {
			for view in views {
				view.transform = t
			}
		}
	}

}
