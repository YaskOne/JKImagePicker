//
//  JKCameraViewController.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 30/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import AVFoundation
import UIKit

struct JKCameraSettings {
	var mirrorHorizontally: Bool = true
}

class JKCameraViewController: JKImagePickerSourceViewController {
	
	/// cameraPreview
	///
	/// The cameraPreview's job is to capture video data and provide convenient accessors to camera device settings
	
	var cameraPreview: JKCameraPreview?
	
	/// controlView
	///
	/// The controlView is reponsible of handling gestures ( pinch, pan, tap, motion ) and display camera device controls. ( focus, exposure )
	
	var controlView: JKCameraControlView?
	
	
	var capturePhotoOutput: AVCapturePhotoOutput? { get {
		return cameraPreview?.capturePhotoOutput
		}}
	
	//MARK: - Settings
	
	var settings: JKCameraSettings = JKCameraSettings()
	
	var avSettings: AVCapturePhotoSettings {
		get {
			let settings = AVCapturePhotoSettings()
			settings.isAutoStillImageStabilizationEnabled = false
			settings.isHighResolutionPhotoEnabled = true
            settings.flashMode = hasFlash ? flashMode : .off
			return settings
		}
	}
	
	var flashModeIndex = 0
	var flashMode : AVCaptureDevice.FlashMode { get {
		return flashModes[flashModeIndex % flashModes.count]
		} set {
			flashModeIndex = flashModes.index(of: newValue) ?? 0
		}}
	var flashModes : [AVCaptureDevice.FlashMode] = [.off, .on, .auto]

	var hasFlash: Bool { get {
		if let flash = cameraPreview?.currentDevice?.hasFlash {
			return flash
		}
		return false
		}}
	
	//MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()

		let cameraPreview = JKCameraPreview(frame: view.bounds)
		view.addSubview(cameraPreview)
		cameraPreview.startCamera()
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
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		UIDevice.current.beginGeneratingDeviceOrientationNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self)
		UIDevice.current.endGeneratingDeviceOrientationNotifications()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		cameraPreview?.frame = view.bounds
		controlView?.frame = view.bounds
	}
	


    //MARK: - Notifications
    
    @objc override func orientationChanged(notif: Notification) {
		super.orientationChanged(notif: notif)
        controlView?.orientation = orientation
		
	}
	
	@IBOutlet var flashIndicator: UIView?
	
	@objc func flashAvailabilityChanged(notification: Notification) {
		
	}
	
	@objc func flashActiveChanged(notification: Notification) {
		guard let capture = self.cameraPreview?.capturePhotoOutput else { return }
		UIView.animate(withDuration: 0.3) {
			self.flashIndicator?.alpha = capture.isFlashScene ? 0.5 : 0
		}
	}

	
	//MARK: - Buttons delegate
	
	override var availableControls: [JKCameraControlItem] { get {
		let flashItem: JKCameraControlItem = hasFlash ? .flash : .pad
		return [flashItem,.switchCam,.gallery,.pad,.pad,.pad,.close]
		}}
	
	override func iconForControlItem(_ item:JKCameraControlItem) -> String {
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
	
	override func commandButtonTapped(command: JKCameraCommand) {
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
	
	func switchCamera() {
		cameraPreview?.switchCamera()
		stateChanged()
	}
	
	func nextFlashMode() {
		flashModeIndex = (flashModeIndex + 1) % flashModes.count
		stateChanged()
	}

}

extension JKCameraViewController : AVCapturePhotoCaptureDelegate   {

	func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		print("Capture will begin")
	}

	// func called when a photo is taken
	func photoOutput(_ captureOutput: AVCapturePhotoOutput,
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
		cameraPreview?.stopCamera()
		
		// Initialise a UIImage with our image data
		if let capturedImage = UIImage.init(data: imageData, scale: 1.0) {
			
			let image = processImage(image: capturedImage)
			
			// Let the time to see the obturation and the picture
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				self.delegate?.pictureAvailable(image)
			}
		}
	}
    
    func processImage(image: UIImage) -> UIImage {
        var output = image
		var mirrored = false
		if settings.mirrorHorizontally {
			mirrored = cameraPreview?.cameraPosition == .back
		}

		output = output.fromAVCapture(withDeviceOrientation: orientation, flip:mirrored)

        return output //.standardized
    }
	
	func registerToInputPortFormatChange() {
		NotificationCenter.default.addObserver(self, selector: #selector(avCaptureInputPortFormatChanged(notification:)), name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
	}
	
	@objc func avCaptureInputPortFormatChanged(notification: Notification) {
		if let format = cameraPreview?.currentDevice?.activeFormat {
			print(format.formatDescription)
		let dimensions: CMVideoDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
			
		JKImageFormatRatio.cameraFrame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(dimensions.height), height: CGFloat(dimensions.width) )
		JKImageFormatRatio.screenFrame = view.bounds
	
		}
	}
}

//MARK: - Capture

extension JKCameraViewController {
	
	func capturePhoto() {
		// Make sure capturePhotoOutput is valid
		guard isEnabled, let capturePhotoOutput = self.capturePhotoOutput else {
			return
		}
		obture()
		isEnabled = false
		// Call capturePhoto method by passing our photo settings and a
		// delegate implementing AVCapturePhotoCaptureDelegate
		capturePhotoOutput.capturePhoto(with: avSettings, delegate: self)
	}
	
	func obture() {
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



