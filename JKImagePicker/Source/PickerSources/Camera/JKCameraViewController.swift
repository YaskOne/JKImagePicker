//
//  JKCameraViewController.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 30/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import AVFoundation
import UIKit

public struct JKCameraSettings {
	var mirrorHorizontally: Bool = true
}

public class JKCameraViewController: JKImagePickerSourceViewController {
	
	/// cameraPreview
	///
	/// The cameraPreview's job is to capture video data and provide convenient accessors to camera device settings
	
	public var cameraPreview: JKCameraPreview?
	
	/// controlView
	///
	/// The controlView is reponsible of handling gestures ( pinch, pan, tap, motion ) and display camera device controls. ( focus, exposure )
	
	public var controlView: JKCameraControlView?
	
	
	public var capturePhotoOutput: AVCapturePhotoOutput? { get {
		return cameraPreview?.capturePhotoOutput
		}}
	
	//MARK: - Settings
	
	public var settings: JKCameraSettings = JKCameraSettings()
	
	public var avSettings: AVCapturePhotoSettings {
		get {
			let settings = AVCapturePhotoSettings()
			settings.isAutoStillImageStabilizationEnabled = false
			settings.isHighResolutionPhotoEnabled = true
            settings.flashMode = hasFlash ? flashMode : .off
			return settings
		}
	}
	
	public var flashModeIndex = 0
	public var flashMode : AVCaptureDevice.FlashMode { get {
		return flashModes[flashModeIndex % flashModes.count]
		} set {
			flashModeIndex = flashModes.index(of: newValue) ?? 0
		}}
	public var flashModes : [AVCaptureDevice.FlashMode] = [.off, .on, .auto]

	public var hasFlash: Bool { get {
		if let flash = cameraPreview?.currentDevice?.hasFlash {
			return flash
		}
		return false
		}}
	
	//MARK: - Lifecycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()

		let cameraPreview = JKCameraPreview(frame: view.bounds)
		view.addSubview(cameraPreview)

        self.cameraPreview = cameraPreview
		
		let controlView = JKCameraControlView(frame: view.bounds)
		view.addSubview(controlView)
		controlView.setup()
		controlView.camera = cameraPreview
		self.controlView = controlView
		
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(flashAvailabilityChanged(notification:)), name: JKCameraPreview.flashReadyChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(flashActiveChanged(notification:)), name: JKCameraPreview.flashActiveChangedNotification, object: nil)
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
		
		registerToInputPortFormatChange()
		
		flashIndicator?.layer.cornerRadius = 7
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
		UIDevice.current.endGeneratingDeviceOrientationNotifications()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cameraPreview?.frame = view.bounds
		controlView?.frame = view.bounds
	}
	
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("$$$$$$$$ MEMORY WARNING IN JACK CAMERA VIEW CONTROLLER $$$$$$$$$$$")
    }


    //MARK: - Notifications
    
    @objc public override func orientationChanged(notif: Notification) {
		super.orientationChanged(notif: notif)
        controlView?.orientation = orientation
		
	}
	
	@IBOutlet public var flashIndicator: UIView?
	
	@objc public func flashAvailabilityChanged(notification: Notification) {
		
	}
	
	@objc public func flashActiveChanged(notification: Notification) {
		guard let capture = self.cameraPreview?.capturePhotoOutput else { return }
		UIView.animate(withDuration: 0.3) {
			self.flashIndicator?.alpha = capture.isFlashScene ? 0.5 : 0
		}
	}

	
	//MARK: - Buttons delegate
	
	override public var availableControls: [JKCameraControlItem] { get {
		let flashItem: JKCameraControlItem = hasFlash ? .flash : .pad
		return [flashItem,.switchCam,.gallery,.free,.free,.free,.close]
		}}
	
	override public func iconForControlItem(_ item:JKCameraControlItem) -> String {
		if item == .flash {
			switch flashMode {
			case .off:
				return JackImagePickerFont.icon_flash_off
			case .on:
				return JackImagePickerFont.icon_flash_on
			case .auto:
				return JackImagePickerFont.icon_flash_auto
			}
		}
		return super.iconForControlItem(item)
	}
	
	override public func commandButtonTapped(command: JKCameraCommand) {
		switch command {
		case JKCameraControlItem.switchCam.rawValue:
			switchCamera()
			break
		case JKCameraControlItem.flash.rawValue:
			nextFlashMode()
			break
		default:
			delegate?.commandButtonTapped(command: command)
			break
		}
	}
	
	public func switchCamera() {
		cameraPreview?.switchCamera()
		stateChanged()
	}
	
	public func nextFlashMode() {
		flashModeIndex = (flashModeIndex + 1) % flashModes.count
		stateChanged()
	}

}

extension JKCameraViewController : AVCapturePhotoCaptureDelegate   {

	public func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		print("Capture will begin")
	}

	// func called when a photo is taken
	public func photoOutput(_ captureOutput: AVCapturePhotoOutput,
					 didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
					 previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
					 resolvedSettings: AVCaptureResolvedPhotoSettings,
					 bracketSettings: AVCaptureBracketedStillImageSettings?,
					 error: Error?) {
		
		isEnabled = true

		// Make sure we get some photo sample buffer
		guard error == nil,
			let photoSampleBuffer = photoSampleBuffer else {
				print("Error capturing photo: \(String(describing: error))")
				return
		}
		
		// Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
		guard let imageData =
			AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
				return
		}
		
		// Initialise a UIImage with our image data
		if let capturedImage = UIImage.init(data: imageData, scale: 1.0) {
			
			let image = processImage(image: capturedImage)
			
			// Let the time to see the obturation and the picture
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				self.delegate?.pictureAvailable(image)
			}
		}
	}
    
    public func processImage(image: UIImage) -> UIImage {
        var output = image
		var mirrored = false
		if settings.mirrorHorizontally {
			mirrored = cameraPreview?.cameraPosition == .back
		}

		output = output.fromAVCapture(withDeviceOrientation: orientation, flip:mirrored)

        return output //.standardized
    }
	
	public func registerToInputPortFormatChange() {
		NotificationCenter.default.addObserver(self, selector: #selector(avCaptureInputPortFormatChanged(notification:)), name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
	}
	
	@objc public  func avCaptureInputPortFormatChanged(notification: Notification) {
		if let format = cameraPreview?.currentDevice?.activeFormat {
			print(format.formatDescription)
            let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            
            JKImageFormatRatio.cameraFrame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(dimensions.height), height: CGFloat(dimensions.width) )
            JKImageFormatRatio.screenFrame = view.bounds
            delegate?.cameraResolutionLoaded()
		}
	}
}

//MARK: - Capture

public extension JKCameraViewController {
	
	public func capturePhoto() -> Bool {
		// Make sure capturePhotoOutput is valid
		guard isEnabled, let capturePhotoOutput = self.capturePhotoOutput else {
			return false
		}
		obture()
		isEnabled = false
		// Call capturePhoto method by passing our photo settings and a
		// delegate implementing AVCapturePhotoCaptureDelegate
		capturePhotoOutput.capturePhoto(with: avSettings, delegate: self)
        return true
	}
	
	public func obture() {
		let blackView = UIView(frame: view.bounds)
		blackView.backgroundColor = UIColor.black
		blackView.alpha = 0
		cameraPreview?.addSubview(blackView)
		UIView.animate(withDuration: 0.3, delay: 0, options: .autoreverse, animations: {
			blackView.alpha = 1
		}) { finished in
			blackView.removeFromSuperview()
		}
	}
	
}



