//
//  JKHandleView.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 10/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

protocol JKHandleDelegate {
	func handleActivated(handle: JKHandleView)
	func handleDeactivated(handle: JKHandleView)
	
	func handleMoved(handle: JKHandleView)
	
	func handleLocked(handle: JKHandleView)
	func handleUnlocked(handle: JKHandleView)
}

class JKHandleView : UIView {
	
	var delegate: JKHandleDelegate?
	
	var name: String = "Unnamed"
	
	var point: CGPoint = CGPoint.zero { didSet {
		frame = frameForPoint(point: point)
		}}
	
	func frameForPoint(point: CGPoint) -> CGRect {
		let s = scale * size / 2
		let p = point
		return CGRect(x: p.x - s, y: p.y - s, width: 2 * s, height: 2 * s)
	}
	
	var locked: Bool = false { didSet {
		if !locked {
			lockTimer?.invalidate()
			lockTimer = nil
		}
		if locked == oldValue { return }
		if !locked {
			delegate?.handleUnlocked(handle: self)
		}
		filled = locked && active
		stroke = locked ? (active ? 3 : 2) : 1
		}}
	
	var active: Bool = false { didSet {
		locked = false
		filled = locked && active
		stroke = locked ? (active ? 3 : 2) : 1
		}}
	
	var filled: Bool = false { didSet {
		setNeedsLayout()
		setNeedsDisplay()
		}}
	var stroke: CGFloat = 1 { didSet {
		setNeedsLayout()
		setNeedsDisplay()
		}}
	
	var size: CGFloat = 60 { didSet {
		self.frame = frameForPoint(point: point)
		}}
	
	var scale: CGFloat = 1.0 { didSet {
		self.frame = frameForPoint(point: point)
		}}
	
	override func layoutSubviews() {
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = stroke
		layer.backgroundColor = filled ? UIColor.white.withAlphaComponent(0.3).cgColor : UIColor.clear.cgColor
		clipsToBounds = false
	}
	
	//MARK: - Activation
	
	var activateTimer:Timer?
	var activateAnimationTimer: Timer?
	
	func moveTo(_ point: CGPoint) {
		self.point = point
		self.locked = false
		if active {
			self.delegate?.handleMoved(handle: self)
		}
	}
	
	func activate() {
		alpha = 0
		filled = false
		stopActivationTimers()
		
		activateAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false, block: { _ in
			self.scale = 4
			UIView.animate(withDuration: 0.3, delay: 0, options:.curveEaseOut, animations: {
				self.scale = CGFloat(1)
				self.alpha = 1
			})
		})
		
		activateTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { _ in
			self.active = true
			self.delegate?.handleActivated(handle: self)
			
			if self.canLock {
				self.startLocking()
			}
		})
	}
	
	func deactivate(handler: @escaping ()->Void) {
		stopActivationTimers()
		if locked || !active { return }
		self.delegate?.handleDeactivated(handle: self)
		
		UIView.animate(withDuration: 0.3, delay: 0, options:.curveEaseOut, animations: {
			self.scale = CGFloat(0)
			self.alpha = 0
			self.active = false
			handler()
		})
	}
	
	func stopActivationTimers() {
		if let timer = self.activateTimer {
			timer.invalidate()
			activateTimer = nil
		}
		
		if let timer = self.activateAnimationTimer {
			timer.invalidate()
			activateAnimationTimer = nil
		}
	}
	
	//MARK: - Locking
	
	var canLock = false
	var lockTimer: Timer?
	
	func startLocking() {
		if let timer = self.lockTimer {
			timer.invalidate()
			lockTimer = nil
		}
		
		lockTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
			self.locked = true
			self.lockTimer = nil
			self.delegate?.handleLocked(handle: self)
		})
	}
}

