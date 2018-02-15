//
//  JKImagePickerViewController.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 29/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import AVFoundation

public protocol JKImagePickerDelegate {
    func imagePickerSuccess(image: JKImageRepresentable)
    func imagePickerCancel()
}

public enum PickerType {
    case camera
    case gallery
    case still
}

public enum PickerFeature {
	case normal
	case split
}

public class JKImagePickerViewController: JKOrientatedViewController {
	
    public var delegate: JKImagePickerDelegate? = nil
	
    public var _settings: JKPickerSettings? {
        didSet {
            if let formatRatios = _settings?.formatRatios {
                availableRatios = formatRatios
                JKImageFormatRatio.screenFrame = self.view.bounds
                JKImageFormatHelper.shared.format = availableRatios[0]
            }
            
            if let _ = self.view {
                updateInterfaceAfterSettingsChange()
            }
        }
    }
	
	public lazy var formatHelper = { return JKImageFormatHelper(formats: self.settings.formatRatios, format: nil) }()
	
	public var settings: JKPickerSettings { get {
			return _settings ?? JKPickerSettings.default
		}
		set {
			_settings = newValue
		}
	}
	
	public func instantiatePicker(identifier: String) -> JKImagePickerSourceViewController {
		print("Instantiate view controller '\(identifier)")
		return JKImagePicker.storyboard.instantiateViewController(withIdentifier: identifier) as! JKImagePickerSourceViewController
	}
	
	public lazy var cameraVC: JKCameraViewController = { return instantiatePicker(identifier: "Camera") as! JKCameraViewController }()
	public lazy var previewVC: JKStillImageSourceViewController = { return instantiatePicker(identifier: "Preview") as! JKStillImageSourceViewController }()
	public lazy var galleryVC: JKGalleryViewController = { return instantiatePicker(identifier: "Gallery") as! JKGalleryViewController }()

	public func pickerViewController(with type:PickerType) -> JKImagePickerSourceViewController {
		switch type {
		case .camera:
			return cameraVC
		case .gallery:
			return galleryVC
		case .still:
			return previewVC
		}
	}
    
    var blockOverlay: UIView? = nil
    
    func lockOverlay() {
        guard let window = self.view.window else {
            return
        }
        let view = UIView(frame: window.bounds)
        window.addSubview(view)
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        blockOverlay = view
    }
    
    func unlockOverlay() {
        blockOverlay?.removeFromSuperview()
        blockOverlay = nil
    }
    
	public var currentPickerController: JKImagePickerSourceViewController? { didSet {
		updateInterface()
		}}
	
    public var pickerControls: JKPickerButtonsViewController?
    public var pickerActions: JKPickerActionsViewController?
	
	//MARK: - Features
	
	public var featureVC : JKFeatureViewController?  { didSet {
		updateInterface()
		}}

	public var featureControls: [JKCameraControlItem]? {
		get {
			return featureVC?.controlItems
		}
	}
	
	public var currentPicker: PickerType = .camera
	
	public var currentFeature: PickerFeature = .normal {
		didSet {
			switch currentFeature {
			case .normal:
				removeFeature(animated: true)
				break
			case .split:
				loadFeature(named:"Split", animated: true)
                if let splitVC = featureVC as? JKSplitViewController {
                    splitVC.view.isUserInteractionEnabled = settings.hasFreeSplit
                    splitVC.touchAngleControl.isUserInteractionEnabled = settings.hasFreeSplit
                }
				break
			}
			updateInterface()
		}}
	
	//MARK: - Format
	
	public var imageFormat: JKImageFormat = JKImageFormat(ratio: JKImageFormatRatio.fullScreen, orientation: JKImageFormatOrientation.portrait)
	
	public var availableRatios = JKPickerSettings.default.formatRatios
	
	public var image: JKImage?

	public var composition: JKComposition?
	
	@IBOutlet public var formatButton: UIButton!
	
	//MARK: - Lifecycle
	
    override public func viewDidLoad() {
        super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(formatChanged(notif:)), name: JKImageFormatHelper.changed, object: nil)
        updateInterfaceAfterSettingsChange()
        updateFormat()
	}
    
    override public func viewWillAppear(_ animated: Bool) {
        setPicker(.camera)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        cameraVC.cameraPreview?.stopCamera()
        
        super.viewWillDisappear(animated)
    }
	
	@objc public func formatChanged(notif: Notification) {
		if let formatRatio = notif.userInfo?[JKImageFormatHelper.key] as? JKImageFormatRatio {
			imageFormat.ratio = formatRatio
		}
	}
	
	public func updateFormat() {
		let format = JKImageFormatHelper.shared.format
		var ratio = format.ratio
		
		if orientation == .landscapeLeft || orientation == .landscapeRight {
			ratio = 1/ratio
		}
		
		cameraVC.ratio = ratio
        previewVC.ratio = ratio
        if let vc = currentPickerController {
        previewVC.view.frame = vc.view.frame
        }
		
		if let vc = currentPickerController {
			featureVC?.view.frame = vc.view.frame
		}
		
		formatButton.setTitle(format.label, for: .normal)
	}
	
	public func setPicker(_ type: PickerType, animated: Bool = true) {
        
		if type == self.currentPicker && currentPickerController != nil { return }
        
        if type == .camera {
            cameraVC.cameraPreview?.startCamera()
        }
        
		let newPicker = pickerViewController(with: type)
		setupPicker(newPicker)
		
		let currentPickerView = currentPickerController?.view
		let newPickerView = pickerView(for: type)
		newPickerView.alpha = 0
		newPicker.ratio = imageFormat.ratio.ratio

		view.insertSubview(newPickerView, at: 0)
		UIView.animate(withDuration: 0.3, animations: {
			currentPickerView?.alpha = 0.0
			newPickerView.alpha = 1.0
			self.updateControls(for: type)
		}) { _ in
			currentPickerView?.removeFromSuperview()
			self.currentPickerController = newPicker
			self.currentPicker = type
		}
	}
	
	
	public func pickerView(for pickerType: PickerType) -> UIView {
		let vc = pickerViewController(with: pickerType)
		return vc.view
	}
	
	public func setupPicker(_ pickerViewController: JKImagePickerSourceViewController) {
		pickerViewController.delegate = self
		if pickerViewController.parent == nil {
			addChildViewController(pickerViewController)
		}
		pickerControls?.delegate = pickerViewController
	}
	
	public func updateControls(for pickerType: PickerType) {
		switch pickerType {
		case .camera:
				formatButton?.isHidden = availableRatios.count < 2
				pickerActions?.view.isHidden = false
				self.pickerActions?.needsConfirm = false
				featureVC?.view.isHidden = false
			
		case .still:
				formatButton?.isHidden = availableRatios.count < 2
				pickerActions?.view.isHidden = false
				self.pickerActions?.needsConfirm = true
				featureVC?.view.isHidden = false
		case .gallery:
				formatButton?.isHidden = true
				pickerActions?.view.isHidden = true
				self.pickerActions?.needsConfirm = false
				featureVC?.view.isHidden = true
		}
		
		updateInterface()
	}
	
	public func updateInterfaceAfterSettingsChange() {
		formatButton.isHidden = availableRatios.count < 2
		if settings.orientationLock {
			self.orientation = .portrait
		}
		imageFormat = JKImageFormat(ratio: availableRatios[0], orientation: orientation.isPortrait ? .portrait : .landscape)
		if let t = transform {
			updateOrientation(transform: t)
		}
	}
	
	public override func orientationChanged(notif: Notification) {
		if !settings.orientationLock {
			super.orientationChanged(notif: notif)
		}
	}
	
	public func updateInterface() {
		currentPickerController?.featureControls = featureControls
		pickerControls?.reload()
        currentPickerController?.ratio = imageFormat.ratio.ratio
        previewVC.ratio = imageFormat.ratio.ratio
	}
	
	public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pickerControlsSegue" {
            if let pickerControls = segue.destination as? JKPickerButtonsViewController {
                let _ = pickerControls.view        // load view
                self.pickerControls = pickerControls
            }
        }
        else if segue.identifier == "pickerActionsSegue" {
            if let pickerActions = segue.destination as? JKPickerActionsViewController {
                let _ = pickerActions.view        // load view
                pickerActions.delegate = self
                self.pickerActions = pickerActions
            }
        }
    }

	public override func updateOrientation(transform t: CGAffineTransform) {
		updateFormat()
		previewVC.view.transform = t
	}
}

extension JKImagePickerViewController: JKImagePickerSourceDelegate {
	
	public func pictureAvailable(_ image: UIImage) {
        unlockOverlay()

        if let cgImage = image.cgImage {
			self.image = JKImage(cgImage, format: imageFormat)
			previewVC.jkImage = self.image
		}
		else {
			previewVC.image = image
		}

        if !settings.hasConfirmation
            && (currentPickerController is JKCameraViewController)
            && featureVC == nil {
            pickerAction(action: .confirm)
            return
        }

		if let split = featureVC as? JKSplitViewController {
			split.image = image
			
			if split.image2 != nil {
                pickerActions?.needsConfirm = true
				split.jkImage2 = self.image
				setPicker(.still)
			} else {
				split.jkImage1 = self.image
				setPicker(.camera)
			}
		}
        else {
            pickerActions?.needsConfirm = true
            setPicker(.still)
        }
	}
	
	public func commandButtonTapped(command: JKCameraCommand) {
		switch command {
		case JKCameraControlItem.close.rawValue:
            print("CLOSING")
			delegate?.imagePickerCancel()
			
		case JKCameraControlItem.camera.rawValue:
			setPicker(.camera)
			
		case JKCameraControlItem.gallery.rawValue:
            
            JKImagePicker.checkGalleryAuthorization(error: {
                print("Not authorized for gallery access")
            }, success: {
                DispatchQueue.main.async {
                    self.setPicker(.gallery)
                }
            })
			
		default:
			featureVC?.commandButtonTapped(command: command)
			pickerControls?.reload()
			break
		}
	}

	public func iconForControlItem(_ item:JKCameraControlItem) -> String {
		if let vc = featureVC, let icon = vc.iconForControlItem(item) {
			return icon
		}
		return item.defaultIcon
	}

	public func stateChanged() {
		self.updateInterface()
	}
    
    public func cameraResolutionLoaded() {
        updateFormat()
    }
	
	public func enabledStateChanged(_ enabled: Bool) {
		pickerActions?.view.alpha = enabled ? 1.0 : 0.4
		pickerActions?.view.isUserInteractionEnabled = enabled
	}

	//MARK: - IBActions
	
	
	@IBAction func formatButtonTapped() {
		formatHelper.nextFormat()
		updateFormat()
	}
	
	
}

//MARK: - Picker Actions

extension JKImagePickerViewController: PickerActionsDelegate {
	
    public func pickerAction(action: PickerAction) {
		switch action {
		case .normal:
			if currentPickerController == cameraVC {
                if cameraVC.capturePhoto() {
                    lockOverlay()
                }
			}
		case .splitted:
			if let splitVC = featureVC as? JKSplitViewController {
				if splitVC.image1 != nil && splitVC.image2 != nil {
					pickerActions?.needsConfirm = false
					return
				}
				if currentPickerController == cameraVC  {
                    if cameraVC.capturePhoto() {
                        lockOverlay()
                    }
					return
				}
/*
				if currentPickerController == previewVC, let image = self.image  {
					pictureAvailable(image)
					return
				}
*/
			}
			
		case .confirm:
			//TODO: Do a clean FeatureViewController that holds the composition object
			//TODO: Embed Settings in composition
			
			switch currentPicker {
			case .camera:
				// Should not happen, since mode gets back to still just after an image has been selected in Camera
                if let jkImage = self.image {
                    delegate?.imagePickerSuccess(image: jkImage)
                }
				break
			case .gallery:
				// Should not happen, since mode gets back to still just after an image has been selected in Gallery
				break
			case .still:
				if let feature = featureVC as? JKSplitViewController {
					if let jkImage1 = feature.jkImage1,
						let jkImage2 = feature.jkImage2,
						let settings = feature.splitView?.settings {
						let splitComposition = JKSplitComposition(angle: settings.angle, center: settings.center)
						splitComposition.image1 = jkImage1
						splitComposition.image2 = jkImage2
						delegate?.imagePickerSuccess(image: splitComposition)
					}
					return
				}

				if let jkImage = self.image {
						delegate?.imagePickerSuccess(image: jkImage)
				}
			}
		}
		
    }
	
	public func actionSelected(action: PickerAction) {
		switch action {
		case .normal:
			currentFeature = .normal
			if let feature = featureVC as? JKSplitViewController {
				feature.image2 = nil
				feature.image1 = nil
			}
			setPicker(.camera)
		case .splitted:
			if let feature = featureVC as? JKSplitViewController {
				feature.image2 = nil
				feature.image1 = nil
			}
			else {
				currentFeature = .split
			}
			setPicker(.camera)
			break
		case .confirm:
			break
		}
	}

}
