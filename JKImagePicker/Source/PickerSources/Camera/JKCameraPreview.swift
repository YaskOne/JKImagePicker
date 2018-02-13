//
//  CameraPreview.swift
//  JKCamera
//
//  Created by Arthur Ngo Van on 14/01/2018.
//  Copyright © 2018 Aurélien GIRARDEAU. All rights reserved.
//

import UIKit
import AVFoundation


public class JKCameraPreview: UIView {
	public static let didLockNotification = Notification.Name("cameraDidLock")
	public static let didUnlockNotification = Notification.Name("cameraDidUnlock")
	public static let isoChangedNotification = Notification.Name("isoChanged")
	public static let flashActiveChangedNotification = Notification.Name("flashActive")
	public static let flashReadyChangedNotification = Notification.Name("flashReady")

	public var cameraPosition: AVCaptureDevice.Position = .back
    
	public var preview: AVCaptureVideoPreviewLayer {
		return self.layer as! AVCaptureVideoPreviewLayer
	}
	
	public override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
	
	public var session: AVCaptureSession? {
		get { return preview.session }
		set { preview.session = newValue }
	}

    public var currentDevice: AVCaptureDevice? = nil
    
    /// helps us to transfer data between one or more device inputs like camera or microphone
    public var captureSession: AVCaptureSession?
    
    // Instance proprerty on this view controller class
    public var isCaptureSessionConfigured = false
    
    /// helps us to snap a photo from our capture session
    public var capturePhotoOutput: AVCapturePhotoOutput?
	
    public var exposureDelay: DispatchWorkItem? = nil
	public var _zoom: CGFloat = 1
	public var _focusPoint: CGPoint?
	
    private static let orientationMap: [UIDeviceOrientation : AVCaptureVideoOrientation] = [
        .portrait           : .portrait,
        .portraitUpsideDown : .portraitUpsideDown,
        .landscapeLeft      : .landscapeRight,
        .landscapeRight     : .landscapeLeft,
        ]
    
    
    public func startCamera() {
		backgroundColor = UIColor.red
		self.configureCaptureSession({ success, avCapturePhotoOutput in
			guard let session = self.captureSession, success else { return }
			
			// redimesions the camera preview
			preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
			// mirrors the image when front facing
			preview.connection?.automaticallyAdjustsVideoMirroring = false
			
			preview.connection?.isVideoMirrored = self.cameraPosition == .front
			
			self.isCaptureSessionConfigured = true
			session.startRunning()
			self.session = session

			if let device = currentDevice {
				device.addObserver(self, forKeyPath: "adjustingFocus", options: .new, context: nil)
				device.addObserver(self, forKeyPath: "isFlashAvailable", options: .new, context: nil)
				avCapturePhotoOutput.addObserver(self, forKeyPath: "isFlashScene", options: .new, context: nil)
			}
		})
    }
	
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "adjustingFocus" {
			NotificationCenter.default.post(name: JKCameraPreview.isoChangedNotification, object: self, userInfo: change)
		}
		else if keyPath == "isFlashScene" {
			NotificationCenter.default.post(name: JKCameraPreview.flashActiveChangedNotification, object: self, userInfo: nil)
		}
		else if keyPath == "isFlashAvailable" {
			NotificationCenter.default.post(name: JKCameraPreview.flashReadyChangedNotification, object: self, userInfo: nil)
		}
	}
	
	deinit {
		stopCamera()
	}
	
    public func stopCamera() {
		if let device = currentDevice {
			device.removeObserver(self, forKeyPath: "adjustingFocus")
			self.capturePhotoOutput?.removeObserver(self, forKeyPath: "isFlashScene")
			device.removeObserver(self, forKeyPath: "isFlashAvailable")
		}
        if self.captureSession != nil && self.captureSession!.isRunning {
            self.captureSession?.stopRunning()
        }
    }
}

public extension JKCameraPreview {
    
    public func defaultDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: AVMediaType.video,
                                                position: cameraPosition) {
            return device // use default back facing camera otherwise
        } else {
            fatalError("All supported devices are expected to have at least one of the queried capture devices.")
        }
    }
    
	public func configureCaptureSession(_ completionHandler: ((_ success: Bool, _ captureOutput: AVCapturePhotoOutput) -> Void)) {
        var success = false
		let capturePhotoOutput = AVCapturePhotoOutput()

        defer { completionHandler(success, capturePhotoOutput) } // Ensure all exit paths call completion handler.
        
        // Get video input for the default camera.
        currentDevice = defaultDevice()
        captureSession = AVCaptureSession()
        
        guard let videoInput = try? AVCaptureDeviceInput(device: currentDevice!) else {
            print("Unable to obtain video input for default camera.")
            return
        }
        
        // Create and configure the photo output.
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        capturePhotoOutput.isLivePhotoCaptureEnabled = capturePhotoOutput.isLivePhotoCaptureSupported
        
        if self.captureSession == nil {
            return
        }
        // Make sure inputs and output can be added to session.
        guard (self.captureSession?.canAddInput(videoInput))! else { return }
        guard (self.captureSession?.canAddOutput(capturePhotoOutput))! else { return }
        
        // Configure the session.
        self.captureSession?.beginConfiguration()
        self.captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        self.captureSession?.addInput(videoInput)
        self.captureSession?.addOutput(capturePhotoOutput)
        self.captureSession?.commitConfiguration()
        
        self.capturePhotoOutput = capturePhotoOutput
		
		if let photoSettings = captureSession?.outputs.last {
			print(photoSettings)
		}
        success = true
    }
	
	public func motionDetected() {
		switchToAuto()
	}
	
    public func switchToAuto() {
		configure() { device in
		
			if device.isFocusModeSupported(.autoFocus) {
				device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
			}
			if device.isExposureModeSupported(.autoExpose) {
				device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
			}

			if device.isFocusPointOfInterestSupported {
				device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
			}
			if device.isExposurePointOfInterestSupported {
				device.exposurePointOfInterest = CGPoint(x: 0.5, y: 0.5)
			}
		}
    }
	
	public func switchCamera() {
		stopCamera()
		cameraPosition =  cameraPosition == .front ? .back : .front
		startCamera()
	}
	
	public func configure(autoUnlock: Bool = true, handler: @escaping (AVCaptureDevice)->Void) {
		guard let device = currentDevice else { return }
		do {
			try device.lockForConfiguration()
			NotificationCenter.default.post(name: JKCameraPreview.didLockNotification, object: self)

			handler(device)
			
			if (autoUnlock) {
				endConfigure(device: device)
			}
		}
		catch {
			
		}
	}
	
	public func endConfigure(device: AVCaptureDevice) {
		device.unlockForConfiguration()
		NotificationCenter.default.post(name: JKCameraPreview.didUnlockNotification, object: self)
	}
	
}


public protocol CameraPreviewProtocol {
	var zoom : CGFloat { get set }
	var iso: Float { get set }
	var focusPoint: CGPoint? { get set }
}

extension JKCameraPreview: CameraPreviewProtocol {

	public var zoom : CGFloat { get {
        return _zoom
		}
		set {
			configure() { device in
					device.videoZoomFactor = max(1, min(newValue, device.activeFormat.videoMaxZoomFactor))
					self._zoom = device.videoZoomFactor
				}
		}}
	
	public var iso: Float { get {
		guard let device = currentDevice else { return 0 }
		return (device.iso - device.activeFormat.minISO)  / (device.activeFormat.maxISO - device.activeFormat.minISO)
		}
		
		set {
			configure(autoUnlock: false) { device in
				if device.isExposureModeSupported(AVCaptureDevice.ExposureMode.custom) {
					device.exposureMode = AVCaptureDevice.ExposureMode.custom
					device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: device.activeFormat.minISO + (device.activeFormat.maxISO - device.activeFormat.minISO) * newValue, completionHandler: { (time) -> Void in
						self.endConfigure(device: device)
					})
				}
			}
		}}
	
	public var focusPoint: CGPoint? { get {
		return _focusPoint ?? CGPoint(x: bounds.width / 2, y: bounds.height / 2)
		}
	
		set {
		_focusPoint = newValue
		guard let p = _focusPoint else {
			switchToAuto()
			return
		}
			
        let x = p.y / bounds.height
        let y = 1.0 - p.x / bounds.width
        let deviceFocusPoint = CGPoint(x: x, y: y)
        
		configure() { device in
			// set focus
			if device.isFocusPointOfInterestSupported {
				device.focusPointOfInterest = deviceFocusPoint
				device.focusMode = .autoFocus
			}
			
			// set exposure
			device.exposurePointOfInterest = deviceFocusPoint
			device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
		}
			
        }}
	
}



