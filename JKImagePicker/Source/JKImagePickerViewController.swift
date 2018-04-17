//
//  JKImagePickerViewController.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 29/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import AVFoundation
import JackFoundation

public protocol JKImagePickerDelegate {
    func imagePickerSuccess(image: JKImageRepresentable, metaData: JsonDict?)
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
            guard let settings = _settings else {
                return
            }

            availableRatios = settings.formatRatios
            JKImageFormatRatio.screenFrame = self.view.bounds
            JKImageFormatHelper.shared.format = availableRatios[0]
            
            cameraVC.hasGallery = settings.hasGallery
            cameraVC.orientationLocked = settings.orientationLock
            cameraVC.cameraPreview?.cameraPosition = settings.startPosition
            
			
            if let _ = self.view {
                updateInterfaceAfterSettingsChange()
            }
			
			if let dummyCamera = cameraVC as? JKDevTeamCameraViewController {
				dummyCamera.image1 = settings.dummyImage1
				dummyCamera.image2 = settings.dummyImage2
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
	
	public var userInfo: JsonDict? {
		didSet {
			if let composition = userInfo?["composition"] as? JKSplitComposition,
				let image = userInfo?["sourceImage"] as? UIImage,
				let cgImage = image.cgImage
			{
				self.image = JKImage.init(cgImage)
				
				pickerActions?.actions = [.splitted]
				currentFeature = .split

				if let feature = featureVC as? JKSplitViewController {
					feature.image2 = nil
					feature.image1 = image
					feature.allowsInviteFriends = false
					feature.allowsChangeAngle = false
					feature.splitView.settings = JKSplitSettings(angle: composition.angle, center: composition.center)
				}
			}
			else {
				if settings.startFeature == .split {
					currentFeature = .split
					//self.pickerAction(action: .splitted)
					//self.actionSelected(action: .splitted)
					self.pickerActions?.currentAction = (currentFeature == .split) ? .splitted : .normal
					
				}
			}
		}
	}
	
	public func instantiatePicker(identifier: String) -> JKImagePickerSourceViewController {
		print("Instantiate view controller '\(identifier)")
		return JKImagePicker.storyboard.instantiateViewController(withIdentifier: identifier) as! JKImagePickerSourceViewController
	}
	
    public lazy var cameraVC: JKCameraViewController = {
		if let dummy = settings.dummyImage1 {
			let camVC = instantiatePicker(identifier: "DevCamera") as! JKCameraViewController
			(camVC as? JKDevTeamCameraViewController)?.image1 = settings.dummyImage1
			(camVC as? JKDevTeamCameraViewController)?.image2 = settings.dummyImage2
			return camVC
		} else {
			return instantiatePicker(identifier: "Camera") as! JKCameraViewController
		}
	}()
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
				if (featureVC as? JKSplitViewController) == nil {
					loadFeature(named:"Split", animated: true)
				}
                if let splitVC = featureVC as? JKSplitViewController {
                    splitVC.view.isUserInteractionEnabled = true //settings.hasFreeSplit
                    splitVC.touchAngleControl.isUserInteractionEnabled = settings.hasFreeSplit
					splitVC.allowSoloSplit = settings.allowSoloSplit
					splitVC.splitView.settings.overlayColor = settings.splitColor.cgColor
                }
				break
			}
			updateInterface()
		}}
	
	//MARK: - Format
	
	public var imageFormat: JKImageFormat = JKImageFormat(ratio: JKImageFormatRatio.fullScreen, orientation: JKImageFormatOrientation.portrait)
	
	public var availableRatios = JKPickerSettings.default.formatRatios
	
    public var image: JKImage?
    public var metaData: JsonDict?

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
        image = nil
        
        if let _ = userInfo?["composition"] as? JKSplitComposition,
            let feature = featureVC as? JKSplitViewController {
            feature.image2 = nil
        }
        else if let feature = featureVC as? JKSplitViewController {
            feature.image1 = nil
            feature.image2 = nil
            feature.image = nil
        }
        
        setPicker(.camera)
        cameraVC.cameraPreview?.cameraPosition = settings.startPosition
        cameraVC.cameraPreview?.startCamera()
        
        navigationController?.isNavigationBarHidden = true
		/*
		if settings.startFeature == .split && settings{
			currentFeature = .split
			//self.pickerAction(action: .splitted)
			//self.actionSelected(action: .splitted)
			self.pickerActions?.currentAction = (currentFeature == .split) ? .splitted : .normal

		}
*/

    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        cameraVC.cameraPreview?.stopCamera()
        
        super.viewWillDisappear(animated)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("$$$$$$$$ MEMORY WARNING IN JACK IMAGE PICKER VIEW CONTROLLER $$$$$$$$$$$")
    }
	
	//MARK: - Block Overlay
	
	var blockOverlay: UIView? = nil
	
	func lockOverlay() {
		guard let window = self.view.window else {
			return
		}
		let view = UIView(frame: window.bounds)
		view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
		window.addSubview(view)
		view.isUserInteractionEnabled = true
		blockOverlay = view
	}
	
	func unlockOverlay() {
		blockOverlay?.removeFromSuperview()
		blockOverlay = nil
	}
	

	//MARK: - Format
	
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
	
	//MARK: - Picker selection
	
	public func setPicker(_ type: PickerType, animated: Bool = true) {
        
        if type == .camera {
            cameraVC.cameraPreview?.startCamera()
        }
        
		if type == self.currentPicker && currentPickerController != nil { return }
        
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
	
    public func pictureAvailable(_ image: UIImage?, metaData: JsonDict? = nil) {
        unlockOverlay()

        guard let image = image else {
            print("[JKImagePicker]: error capturing image, try again")
            setPicker(.camera)
            return
        }
        if let cgImage = image.cgImage {
			self.image = JKImage(cgImage, format: imageFormat)
			previewVC.jkImage = self.image
		}
		else {
			previewVC.image = image
		}
        self.metaData = metaData

        if !settings.hasConfirmation && currentPickerController is JKCameraViewController {
            if featureVC == nil || (featureVC as? JKSplitViewController)?.image2 != nil || !settings.allowSoloSplit {
				if let split = featureVC as? JKSplitViewController {
					
					if split.image1 != nil {
						split.jkImage2 = self.image
					} else {
						split.jkImage1 = self.image
					}
				}
                pickerAction(action: .confirm)
                return
            }
        }

		if let split = featureVC as? JKSplitViewController {
			split.image = image
			
			if split.image2 != nil {
                pickerActions?.needsConfirm = true
				split.jkImage2 = self.image
				setPicker(.still)
			} else {
				split.jkImage1 = self.image
				if settings.allowSoloSplit {
					setPicker(.camera)
				}
				else {
					pickerActions?.needsConfirm = true
					setPicker(.still)
				}
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
			
		case JKCameraControlItem.camera.rawValue, JKCameraControlItem.back.rawValue:
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
	
    func completionHandler() {
        cameraVC.cameraPreview?.stopCamera()
    }
    
    public func pickerAction(action: PickerAction) {
		switch action {
		case .normal:
			if currentPickerController == cameraVC {
				if settings.dummyImage1 != nil {
					self.pictureAvailable(settings.dummyImage1!)
					return
				}
                if cameraVC.capturePhoto(completionHandler: completionHandler) {
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
                    if cameraVC.capturePhoto(completionHandler: completionHandler) {
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
			confirm()
		}
		
    }
	
	public func confirm() {
		
		if let feature = featureVC as? JKSplitViewController {
			if let jkImage1 = feature.jkImage1,
				let settings = feature.splitView?.settings {
				let splitComposition = JKSplitComposition(angle: settings.angle, center: settings.center)
				splitComposition.image1 = jkImage1
				splitComposition.image2 = feature.jkImage2
				splitComposition.splitOverlayColor = (settings.overlayColor ?? UIColor.black.cgColor)
				done(image: splitComposition, metaData: self.metaData)
			}
			return
		}

		switch currentPicker {
		case .camera:
			// Should not happen, since mode gets back to still just after an image has been selected in Camera
			if let jkImage = self.image {
				delegate?.imagePickerSuccess(image: jkImage, metaData: self.metaData)
			}
			break
		case .gallery:
			// Should not happen, since mode gets back to still just after an image has been selected in Gallery
			break
		case .still:
			
			if let jkImage = self.image {
				done(image: jkImage, metaData: self.metaData)
			}
		}
	}
	
	func done(image: JKImageRepresentable, metaData: JsonDict?) {
		delegate?.imagePickerSuccess(image: image, metaData: self.metaData)
	}
	
	public func actionSelected(action: PickerAction) {
		switch action {
		case .normal:
			currentFeature = .normal
			self.image = nil
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
