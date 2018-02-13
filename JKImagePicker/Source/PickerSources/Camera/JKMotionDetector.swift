//
//  JKCameraMotionDetector.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 03/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import Foundation
import CoreMotion

public protocol JKMotionDetectorDelegate {
	func motionDetected()
}

public class JKMotionDetector {
	
	var delegate : JKMotionDetectorDelegate
	public let detectionQueue = OperationQueue()
	public let motion = CMMotionManager()
	
	public var interval: Double = 0.2 { didSet { restart() }}
	public var threshold: Double = 0.04
	
	public var referenceAcceleration :  CMAcceleration?
	
	public init(delegate: JKMotionDetectorDelegate) {
		self.delegate = delegate
	}
	
	public var acceleration : CMAcceleration? { didSet {
		
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
	
	public func start() {
		// Make sure the accelerometer hardware is available.
		guard motion.isAccelerometerAvailable else { return }
		motion.accelerometerUpdateInterval = interval
		motion.startAccelerometerUpdates(to: detectionQueue, withHandler: { accelerationData, error in
			if let acceleration = accelerationData?.acceleration {
				self.acceleration = acceleration
			}
		})
	}
	
	public func stop() {
		referenceAcceleration = nil
		motion.stopAccelerometerUpdates()
	}
	
	public func restart() {
		stop()
		start()
	}
}
