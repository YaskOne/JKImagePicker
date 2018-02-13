//
//  JackFocus.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 22/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit


@IBDesignable public class JKCameraControlView: UIView, JKMotionDetectorDelegate {
	
    @IBInspectable public var focusViewSize: CGFloat = 100
    @IBInspectable public var friction: Float = 0.00005
	
    public var camera: CameraPreviewProtocol?

	public var motion: JKMotionDetector?

	public var orientation: UIDeviceOrientation = UIDevice.current.orientation { didSet {
			updateOrientation()
		}}
	
	// Focus
	
	public var focusView : JKCamFocusView?
	
	public var focusPoint : CGPoint? { didSet {
			focusView?.frame = focusViewFrame
		}}
	
	public var focusViewFrame : CGRect { get {
		// if focus point not set, set it to center
		let fp = focusPoint ?? CGPoint(x: bounds.width / 2, y: bounds.height / 2)
		return CGRect(x: fp.x - focusViewSize / 2, y: fp.y - focusViewSize / 2, width: focusViewSize, height: focusViewSize)
		}}

	public var hideFocusTask: DispatchWorkItem? = nil

	// Zoom
	
	public var zoomActionInitialZoom : CGFloat = 1

	// Exposure
	
	public var exposureActionIso : Float = 0.5

	//MARK: -  Lifecycle
	
    public func setup() {
		motion = JKMotionDetector(delegate: self)

		focusPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
		
		let focusView = JKCamFocusView(frame: focusViewFrame)
		
		focusView.setup()
        focusView.alpha = 0
        addSubview(focusView)
		self.focusView = focusView

		// Setup gestures
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        self.addGestureRecognizer(tap)
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchHandler))
        self.addGestureRecognizer(pinch)
		
		let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler))
        self.addGestureRecognizer(pan)
		
		tap.require(toFail: pinch)
		
		// Listen to camera notifications
		
		NotificationCenter.default.addObserver(self, selector: #selector(isoChanged), name: JKCameraPreview.isoChangedNotification, object: nil)
    }
	
	//MARK: - Focus view management
	
    public func showFocus(position: CGPoint?) {
        guard let focus = focusView else { return }
		
		UIView.animate(withDuration: 0.3, animations: {
			self.focusView?.autoFocus = position == nil
			self.focusPoint = position
			focus.alpha = 1.0
		})

        hideFocusAfterDelay()
    }
    
    public func hideFocus() {
		guard let focus = focusView else { return }
		motion?.start()
		UIView.animate(withDuration: 0.3) { focus.alpha = 0 }
    }
    
    public func hideFocusAfterDelay() {
		hideFocusTask?.cancel()
        let newHideFocusTask = DispatchWorkItem { self.hideFocus() }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: newHideFocusTask)
		hideFocusTask = newHideFocusTask
    }
	
	public func motionDetected() {
		motion?.stop()
		DispatchQueue.main.async {
			self.showFocus(position: nil)
			self.camera?.focusPoint = nil
		}
	}
	
    @objc public func pinchHandler(_ gestureRecognizer: UIPinchGestureRecognizer) {
		switch gestureRecognizer.state {
		case .began:
			zoomActionInitialZoom = camera?.zoom ?? 1
		case .changed:
			camera?.zoom = zoomActionInitialZoom * gestureRecognizer.scale
		default:
			break
		}}
    
    @objc public func panHandler(_ pan : UIPanGestureRecognizer) {
		guard var cam = camera else { return }
		
		if focusPoint == nil {
			// Uncoment this to allow exposure setting in autoFocus mode
			//showFocus(position: center)
			return
		}
		
        // Update the position for the .began, .changed, and .ended states
		switch pan.state {
		case .cancelled, .ended, .failed:
			hideFocusAfterDelay()
		case .began:
			exposureActionIso = cam.iso
		default:
			hideFocusTask?.cancel()
			
			var velocity = orientation.isPortrait ? pan.velocity(in: self).y : pan.velocity(in: self).x
			switch orientation {
			case .portraitUpsideDown,.landscapeLeft:
				velocity = -velocity
			default:
				break
			}
			
			let delta = -Float( velocity )  * friction
			exposureActionIso += delta
			if exposureActionIso > 1 {
				exposureActionIso = 1
			} else if exposureActionIso < 0 {
				exposureActionIso = 0
			}
			focusView?.exposure = exposureActionIso
			cam.iso = exposureActionIso
		}
    }
    
    @objc public func tapHandler(_ sender: UITapGestureRecognizer) {
		let touchLocation: CGPoint = sender.location(in: sender.view)
		showFocus(position: touchLocation)
		camera?.focusPoint = touchLocation
    }
	
	//MARK: - Camera Notifications
	
	@objc public func isoChanged() {
		UIView.animate(withDuration: 0.4) {
			self.focusView?.exposure = Float(self.camera?.iso ?? 0.5)
		}
	}

	//MARK: - orientation
	
	public func updateOrientation() {
		guard let t = JKImagePickerUtils.orientationToTransform(orientation) else { return }
		UIView.animate(withDuration: 0.3) {
			self.focusView?.transform = t
		}
	}
}

