//
//  PickerActionsViewController.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 30/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public enum PickerAction: Int {
    case normal
    case splitted
    case confirm
	
    var image: String {
        switch self {
        case .normal:
            return "Capture"
        case .splitted:
            return "Capture-split"
        case .confirm:
            return "Capture-split"
        }
    }
}

public protocol PickerActionsDelegate {
    func pickerAction(action: PickerAction)
	func actionSelected(action: PickerAction)
	
	func availablePickerActions() -> [PickerAction]
	func selectedAction() -> PickerAction
}

public class JKPickerActionsViewController: JKOrientatedViewController {

    private var _actions = [PickerAction]()
	
	public var actions: [PickerAction] {
		get {
            return _actions.isEmpty ? delegate?.availablePickerActions() ?? [] : _actions
		}
		set {
			_actions = newValue
			reloadButtons()
		}
	}
	
    public var actionButtons = [PickerAction: UIButton]()
    public var actionConfirmLabel = [PickerAction: UILabel]()

	public var delegate: PickerActionsDelegate? { didSet {
		reloadButtons()
		}}

	public var needsConfirm: Bool = false {
		didSet {
			updateActions()
			updateLayout()
		}}
	
    public var currentAction: PickerAction = .normal {
        didSet {
			updateLayout()
			delegate?.actionSelected(action: currentAction)
        }
    }
	
	// Layout
	
    public var xGap: CGFloat { get { return view.bounds.height / 4 } }
    public var yGap: CGFloat { get { return view.bounds.height / 6 } }
	
	public var buttonSize: CGSize { get {
		return CGSize(width:view.bounds.height, height:view.bounds.height)
		} }
	
	public var smallButtonSize: CGSize { get {
		let size = CGSize(width:view.bounds.height, height:view.bounds.height)
		return CGSize(width: size.width * 2 / 3, height: size.height * 2 / 3)
		} }
	
	public func buttonFrameForAction(_ action: PickerAction) -> CGRect {
		var size = CGSize.zero
		var offset = CGPoint.zero
		let s = buttonSize
		let leftMargin = view.bounds.width / 2 - s.width / 2

		// Main button is full size, centered
		if action == currentAction {
			size = s
		}
			
		// else button is offseted and scaled down
		else if let index = (actions.filter{$0 != currentAction}.index{$0==action}) {
			size = smallButtonSize
			offset.x = s.width + xGap + CGFloat(index) * s.width
			offset.y = yGap
		}
		return CGRect(x: leftMargin + offset.x, y: offset.y, width: size.width, height: size.height)
	}
	
	//MARK: - Buttons creation
	
	public func reloadButtons() {
        for action in actionButtons {
            action.value.removeFromSuperview()
        }
        for label in actionConfirmLabel {
            label.value.removeFromSuperview()
        }
        actionButtons = [:]
        actionConfirmLabel = [:]
		for action in actions {
            actionButtons[action] = makeButtonForAction(action)
            actionConfirmLabel[action] = makeLabelForAction(action, superView: actionButtons[action]!)
		}
		currentAction = actions.first ?? .normal
	}
    
    public func makeButtonForAction(_ action: PickerAction) -> UIButton {
        let button = UIButton()
        let label = action.image
        button.accessibilityLabel = label
        button.accessibilityIdentifier = label
        button.setImage(UIImage.init(named: action.image), for: .normal)
        button.tag = action.rawValue
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        return button
    }
    
    public func makeLabelForAction(_ action: PickerAction, superView: UIView) -> UILabel {
        let label = UILabel(frame: insetedFrame(superView))
        label.text = JackImagePickerFont.icon_checkmark
        label.font = UIFont(name: "JackFont", size: label.frame.height)
        superView.addSubview(label)
        return label
    }

    func insetedFrame(_ container: UIView) -> CGRect {
        let containerFrame = CGRect.init(origin: CGPoint.zero, size: container.frame.size)
        return containerFrame.insetBy(dx: containerFrame.height / 4, dy: containerFrame.height / 4)
    }
    
	//MARK: - Layout
	
	public func updateActions() {
		for action in actions {
            if let button = actionButtons[action] {
                button.tag = action.rawValue
                button.setImage(UIImage(named: action.image), for: .normal)
            }
            if let label = actionConfirmLabel[action] {
                label.isHidden = !needsConfirm
            }
		}
//        guard let mainButton = actionButtons[currentAction], needsConfirm else { return }
//        mainButton.tag = PickerAction.confirm.rawValue
//        mainButton.setImage(UIImage(named: PickerAction.confirm.image), for: .normal)
	}
	
	public func updateLayout() {
		for action in actions {
            if let button = actionButtons[action] {
                button.frame = buttonFrameForAction(action)
                if let label = actionConfirmLabel[action] {
                    label.frame = insetedFrame(button)
                }
            }
		}
	}
	
	//MARK: - Lifecycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		currentAction = delegate?.selectedAction() ?? .normal
	}

	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateLayout()
	}
	
	//MARK: - Action
	
    @objc func buttonTapped(_ sender: UIButton) {
		guard let action = PickerAction(rawValue:sender.tag) else { return }
		
		if action != currentAction {
			UIView.animate(withDuration: 0.5) {
				self.currentAction = action
			}
			return
		}
        if needsConfirm {
            delegate?.pickerAction(action: PickerAction.confirm)
            return
        }
		delegate?.pickerAction(action: currentAction)

    }

	public override func updateOrientation(transform t: CGAffineTransform) {
		UIView.animate(withDuration: 0.3) {
			for view in self.actionButtons.values {
				view.transform = t
			}
		}
	}

}
