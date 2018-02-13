//
//  JKCenterAngleControlView.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

import JackFoundation
import iOSCommons

@objc protocol JKCenterAngleControlViewDelegate {
	func centerDidChange(_ center:CGPoint)
	func angleDidChange(_ angle:CGFloat)
}

enum JKCenterAngleControlTouchMode : String {
	case none
	case center
	case handle
	case centerAndHandle
	case handles
}

class JKCenterTouchView : JKHandleView {
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
}

class JKHandleTouchView : JKHandleView {
	override func layoutSubviews() {
		layer.cornerRadius = layer.bounds.width / 2
		super.layoutSubviews()
	}
}

class JKCenterAngleControlView: UIView {

	@IBOutlet var delegate: JKCenterAngleControlViewDelegate?
	
	var touchMode : JKCenterAngleControlTouchMode = .none { didSet {
		if touchMode == .none {
			lineVisible = false
		}
		else {
			lineVisible = true
		}
		}}
	
	var centerTouch: UITouch?
	var handleTouch: UITouch?
	var handleTouch2: UITouch?
	
	var lineVisible: Bool = false { didSet {
		setNeedsDisplay()
		}}
	
	var anchor = CGPoint.zero
	
	var angle: CGFloat = 0 {
		didSet {
			if centerView.active {
				delegate?.angleDidChange(angle)
			}
		}
	}
	
	var centerViewSize: CGFloat = 60
	
	lazy var centerView: JKCenterTouchView = {
		let view = JKCenterTouchView(frame:CGRect.zero)
		view.canLock = true
		view.name = "Center"
		view.delegate = self
		return view
	}()
	
	lazy var handleTouch1View: JKHandleTouchView = {
		let view = JKHandleTouchView(frame:CGRect.zero)
		//view.canLock = true
		view.name = "Handle 1"
		view.delegate = self
		return view
	}()
	
	lazy var handleTouch2View: JKHandleTouchView = {
		let view = JKHandleTouchView(frame:CGRect.zero)
		view.delegate = self
		view.name = "Handle 2"
		return view
	}()
		
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if touches.count == 1 {
			switch touchMode {
			case .none:
				if let touch = touches.first {
					centerTouch = touch
					touchMode = .center
					centerView.point = touch.location(in: self)
					showHandleView(centerView)
				}
			case .center:
				if let touch = touches.first {
					handleTouch = touch
					touchMode = .centerAndHandle
					handleTouch1View.point = touch.location(in: self)
					showHandleView(handleTouch1View)
				}
			case .handle:
				if let touch = touches.first {
					centerTouch = touch
					touchMode = .centerAndHandle
					centerView.point = touch.location(in: self)
					showHandleView(centerView)
				}
				// Two touches - max
			case .centerAndHandle,.handles:
				break
			}
		}
		else if touches.count == 2 {
			switch touchMode {
			case .none:
				let touches = Array(touches)
				handleTouch = touches[0]
				handleTouch2 = touches[1]
				
				let p1 = touches[0].location(in: self)
				let p2 = touches[1].location(in: self)
				handleTouch1View.point = p1
				handleTouch2View.point = p2
				centerView.point = middle(p1: p1, p2: p2)
				touchMode = .handles
				
				showHandleView(handleTouch1View)
				showHandleView(handleTouch2View)
				showHandleView(centerView)

			// Two touches - max
			case .center,.handle,.centerAndHandle,.handles:
				break
			}
		}
	}
	
	func middle(p1: CGPoint,p2: CGPoint) -> CGPoint {
		return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		switch touchMode {
		case .none:
			break
		case .center:
			if let centerTouch = self.centerTouch, touches.contains(centerTouch) {
				self.centerTouch = nil
				if !centerView.locked {
					hideHandleView(centerView) {
						self.touchMode = .none
					}
				}
			}
		case .handle:
			if let handleTouch = self.handleTouch, touches.contains(handleTouch) {
				self.handleTouch = nil
				hideHandleView(handleTouch1View) {
					self.touchMode = .none
				}
			}
		// Two touches - max
		case .centerAndHandle:
			if let touch = self.centerTouch, touches.contains(touch) {
				centerTouch = nil
				touchMode = .handle
			}
			if let touch = self.handleTouch, touches.contains(touch) {
				handleTouch = nil
				hideHandleView(handleTouch1View){
					self.touchMode = .center
				}
			}
			if centerTouch == nil && handleTouch == nil {
				touchMode = .none
				hideHandleView(handleTouch1View) {}
				centerView.locked = false
				hideHandleView(centerView) {}
			}

		case .handles:
			if let handleTouch = self.handleTouch2, touches.contains(handleTouch) {
				self.handleTouch2 = nil
				touchMode = .handle
			}
			if let handleTouch = self.handleTouch, touches.contains(handleTouch) {
				self.handleTouch = handleTouch2
				touchMode = handleTouch2 != nil ? .handle : .none
			}
			if touchMode == .none {
				hideHandleView(centerView) {
					
				}
				hideHandleView(handleTouch1View) {
					
				}
			}
			hideHandleView(handleTouch2View) {
				
			}

		}

	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let centerTouch = self.centerTouch, touches.contains(centerTouch) {
			centerView.moveTo(centerTouch.location(in: self))
		}
		if let handleTouch = self.handleTouch, touches.contains(handleTouch) {
			handleTouch1View.moveTo(handleTouch.location(in: self))
		}
		if let handleTouch = self.handleTouch2, touches.contains(handleTouch) {
			handleTouch2View.moveTo(handleTouch.location(in: self))
		}

	}
	
	func angleBetweenHandleViews(_ v1: JKHandleView, _ v2: JKHandleView) -> CGFloat {
		return angleBetweenPoints(v1.point,v2.point)
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		if lineVisible {
			drawLine()
		}
	}
	
	var phase: CGFloat = 0
	
	func drawLine() {
		let r = sqrt(bounds.width * bounds.width + bounds.height * bounds.height)
		let o = anchor
		let c = cos(angle)
		let s = sin(angle)
		
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		
		let path = CGMutablePath()
		path.move(to: CGPoint(x: o.x + r*c, y: o.y - r*s))
		path.addLine(to: CGPoint(x: o.x - r*c, y: o.y + r*s))
		
		ctx?.setStrokeColor(UIColor.white.cgColor)
		ctx?.setLineDash(phase: phase, lengths: [5,5])
		ctx?.setLineWidth(1)
		ctx?.addPath(path)
		ctx?.strokePath()
		
		ctx?.restoreGState()
	}
	
	func hideHandleView(_ view: JKHandleView, handler: @escaping ()->Void) {
		view.deactivate(handler: handler)
	}
	
	func showHandleView(_ view: JKHandleView) {
		addSubview(view)
		view.activate()
	}
	
	func moveAnchorTo(_ point:CGPoint) {
		anchor = point
		delegate?.centerDidChange(anchor)
		setNeedsDisplay()
	}
	

}

extension JKCenterAngleControlView : JKHandleDelegate {
	
	func handleActivated(handle: JKHandleView) {
		print("Handle Activated : \(handle.name) - mode : \(touchMode)")

		if handle == centerView {
			moveAnchorTo(handle.point)
		}
		if touchMode == .handles {
			centerView.point = middle(p1: handleTouch1View.point, p2: handleTouch2View.point)
			moveAnchorTo(centerView.point)
		}
	}
	
	func handleDeactivated(handle: JKHandleView) {
		print("Handle Deactivated : \(handle.name) - mode : \(touchMode)")
		
	}
	
	func handleMoved(handle: JKHandleView) {
		print("Handle Moved : \(handle.name) - mode : \(touchMode)")
		if handle == centerView {
			moveAnchorTo(handle.point)
		}
		if handle == handleTouch1View {
			if touchMode == .handles {
				centerView.moveTo(middle(p1: handleTouch1View.point, p2: handleTouch2View.point))
				moveAnchorTo(centerView.point)
			}
			angle = angleBetweenHandleViews(centerView, handleTouch1View)
			setNeedsDisplay()
		}
	}
	
	func handleLocked(handle: JKHandleView) {
		print("Handle Locked : \(handle.name) - mode : \(touchMode)")

		if handle == centerView {
			moveAnchorTo(handle.point)
		}
		if handle == handleTouch1View {
			if touchMode == .handles {
				centerView.point = middle(p1: handleTouch1View.point, p2: handleTouch2View.point)
				centerView.locked = true
				moveAnchorTo(centerView.point)
			}
			angle = angleBetweenHandleViews(centerView, handleTouch1View)
			setNeedsDisplay()
		}

	}
	
	func handleUnlocked(handle: JKHandleView) {
		print("Handle Unlocked : \(handle.name) - mode : \(touchMode)")
	}
}

