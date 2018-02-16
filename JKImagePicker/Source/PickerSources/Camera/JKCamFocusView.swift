//
//  JKCamFocusView.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 02/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public class JKCamFocusView: UIView {
    
    public var focusSquare: UIView?
    public var verticalSlider: JKVerticalSlider?
	
	var showSliderInAutofocus = true
	
	public var autoFocus: Bool = true { didSet {
			sliderVisible = !autoFocus
			largeFocus = autoFocus
		}}
	
	public var sliderVisible: Bool = true { didSet {
		verticalSlider?.alpha = showSliderInAutofocus && sliderVisible ? 1 : 0
		}}
	
	public var largeFocus: Bool = false { didSet {
		let o = focusOffset
		let s = focusSize
		focusSquare?.frame = CGRect(x: o, y: o, width: s, height: s)
		verticalSlider?.frame = CGRect(x: o + s + 10, y: 0, width: 23, height: bounds.height)
		}}
	
	public var exposure: Float { set {
		verticalSlider?.value = Double(newValue)
		}
		get {
			return Float(verticalSlider?.value ?? 0)
		}
	}
	
	public var focusOffset: CGFloat { get {
		return largeFocus ? 0 : focusSize / 2
		}}
	
	public var focusSize: CGFloat { get {
		return bounds.width / (largeFocus ? 1 : 2)
		}}
	
    public func setup() {
		let w = focusSize
        focusSquare = UIView(frame: CGRect(x: w / 2, y: w / 2, width: w, height: w))
        verticalSlider = JKVerticalSlider(frame: CGRect(x: w + 10, y: 0, width: w / 2, height: bounds.height))
        autoFocus = true
        focusSquare?.layer.backgroundColor = UIColor.clear.cgColor
        focusSquare?.layer.borderColor = UIColor.white.cgColor
        focusSquare?.layer.borderWidth = 1
		
		focusSquare?.backgroundColor = UIColor.clear
        verticalSlider?.backgroundColor = UIColor.clear
		
		addSubview(focusSquare!)
        addSubview(verticalSlider!)
    }
	
}

