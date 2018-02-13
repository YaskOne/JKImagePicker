//
//  JKCameraMotionDetector.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 03/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import Foundation
import CoreMotion

protocol JKMotionDetectorDelegate {
	func motionDetected()
}

class JKMotionDetector {
	
	var delegate : JKMotionDetectorDelegate
	let detectionQueue = OperationQueue()
	let motion = CMMotionManager()
	
	var interval: Double = 0.2 { didSet { restart() }}
	var threshold: Double = 0.04
	
	var referenceAcceleration :  CMAcceleration?
	
	init(delegate: JKMotionDetectorDelegate) {
		self.delegate = delegate
	}
	
	var acceleration : CMAcceleration? { didSet {
		
		guard let acc = acceleration else { return }
		
		if let ref = referenceAcceleration {
			let dax = acc.x - ref.x
			let day = acc.y - ref.y
			let daz = acc.z - ref.z
			
			if abs(dax) > threshold || abs(day) > threshold || abs(daz) > threshold {
				delegate.motionDetected()
			}
		}
		else {
			referenceAcceleration = acc
		}
		
		}}
	
	func start() {
		// Make sure the accelerometer hardware is available.
		guard motion.isAccelerometerAvailable else { return }
		motion.accelerometerUpdateInterval = interval
		motion.startAccelerometerUpdates(to: detectionQueue, withHandler: { accelerationData, error in
			if let acceleration = accelerationData?.acceleration {
				self.acceleration = acceleration
			}
		})
	}
	
	func stop() {
		referenceAcceleration = nil
		motion.stopAccelerometerUpdates()
	}
	
	func restart() {
		stop()
		start()
	}
}
