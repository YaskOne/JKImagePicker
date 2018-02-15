//
//  JKSplitMode.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 01/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit
import iOSCommons

public enum JKSplitMode: Int {
	case free
	case vertical
	case horizontal
	case diagonalLeft
	case diagonalRight
	
	public static var freeSettings = JKSplitMode.vertical.settings
	
	public static var all:[JKSplitMode] = [.free, .vertical, .horizontal, .diagonalLeft, .diagonalRight]
	
	public var label: String { get {
		switch self {
		case .free:
			return "Free"
		case .horizontal:
			return "Horizontal"
		case .diagonalRight:
			return "Right"
		case .vertical:
			return "Vertical"
		case .diagonalLeft:
			return "Left"
		}
		}}
	
	public var icon: String { get {
		switch self {
		case .free:
			return "?"
		case .horizontal:
			return JackImagePickerFont.icon_split_horizontal
		case .vertical:
			return JackImagePickerFont.icon_split_vertical
		case .diagonalLeft:
			return JackImagePickerFont.icon_split_diagonal_left
		case .diagonalRight:
			return JackImagePickerFont.icon_split_diagonal_right
		}
		}}

    public var settings: JKSplitSettings { get {
        switch self {
        case .free:
            return JKSplitMode.freeSettings
        case .horizontal:
            return JKSplitSettings(angle: 0)
        case .diagonalRight:
            return JKSplitSettings(angle: CGFloat.pi / 4)
        case .vertical:
            return JKSplitSettings(angle: CGFloat.pi / 2)
        case .diagonalLeft:
            return JKSplitSettings(angle: 3 * CGFloat.pi / 4)
        }
        }}

    public func settingsForFrame(frame: CGRect) -> JKSplitSettings {
        switch self {
        case .free:
            return JKSplitMode.freeSettings
        case .horizontal:
            return JKSplitSettings(angle: 0)
        case .diagonalRight:
            return JKSplitSettings(angle: angleBetweenPoints(frame.center, CGPoint(x: frame.maxX, y: 0)))
        case .vertical:
            return JKSplitSettings(angle: CGFloat.pi / 2)
        case .diagonalLeft:
            return JKSplitSettings(angle: angleBetweenPoints(frame.center, CGPoint.zero))
        }
    }
}
