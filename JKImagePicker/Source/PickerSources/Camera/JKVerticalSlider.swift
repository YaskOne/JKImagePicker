//
//  JKVerticalSlider.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 22/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

//TODO: - To Make this class generic and IBDesignable, one must pass the thumb image from controller, and add minValue and maxValue properties

public class JKVerticalSlider: UIView {
    
    public var value: Double = 0.5 {
        didSet {
            if self.value >= 1 {
                self.value = 1
            }
            else if self.value <= 0 {
                self.value = 0
            }
            self.update()
        }
    }
	
	public var maxTrack: UIView? = nil
	public var minTrack: UIView? = nil
	public var thumb: UIImageView? = nil

    /// thumbExtent
	/// the margin around thumbnail
  	public var thumbExtent: CGFloat = 2
    public var thumbHeight: CGFloat = 23
    public var trackWidth: CGFloat = 2
	
	public var trackHeight: CGFloat { get {
			return bounds.height - ( thumbHeight + thumbExtent )
		}}
	
	//MARK: - Layout accessors
	
	public var maxTrackFrame: CGRect { get {
		return CGRect(x: trackMargin, y: 0, width: trackWidth, height: thumbFrameWithExtent.origin.y)
		}}
	
	public var minTrackFrame: CGRect { get {
		let origin = thumbFrameWithExtent.origin.y + thumbFrameWithExtent.height
		return CGRect(x: trackMargin, y: origin, width: trackWidth, height: bounds.height - origin)
		}}

	public var thumbFrame: CGRect { get {
		return CGRect(x: bounds.width / 2 - thumbHeight / 2, y: pixelsValue, width: thumbHeight, height: thumbHeight)
		}}
	
	public var thumbFrameWithExtent: CGRect { get {
		return thumbFrame.insetBy(dx: -thumbExtent, dy: -thumbExtent)
		}}
	
	/// trackMargin
	/// the space between view and track sides
	public var trackMargin: CGFloat { get {
		return (bounds.width - trackWidth) / 2
		}}

	//MARK: - Lifecycle
	
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)!
        self.setup()
    }

    public func setup() {
		maxTrack = UIView(frame: maxTrackFrame)
		minTrack = UIView(frame: minTrackFrame)
		thumb = UIImageView(frame: thumbFrame)
		
		maxTrack?.backgroundColor = UIColor.white
		minTrack?.backgroundColor = UIColor.white
		maxTrack?.layer.cornerRadius = trackWidth / 2
		minTrack?.layer.cornerRadius = trackWidth / 2
		
		thumb?.image = UIImage(named: "Sun")
		
		if let maxTrack = maxTrack, let minTrack = minTrack, let thumb = thumb {
			self.addSubview(maxTrack)
			self.addSubview(minTrack)
			self.addSubview(thumb)
		}
	}
	
    public func update() {
		self.minTrack?.frame = self.minTrackFrame
		self.maxTrack?.frame = self.maxTrackFrame
		self.thumb?.frame = self.thumbFrame
    }
	
	public func pixelsFromValue(_ value: Double) -> CGFloat {
		return trackHeight * ( 1 - CGFloat(value) )
	}
	
	/// Pixels to Value conversion
	/// pixelsValue
	/// The value in pixels
	public var pixelsValue: CGFloat { get {
		return pixelsFromValue(value)
		}}

}
