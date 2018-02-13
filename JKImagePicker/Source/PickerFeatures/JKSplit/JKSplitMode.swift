//
//  JKSplitMode.swift
//  SplitTest
//
//  Created by Tristan Leblanc on 01/02/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

enum JKSplitMode: Int {
	case free
	case vertical
	case horizontal
	case diagonalLeft
	case diagonalRight
	
	static var freeSettings = JKSplitMode.vertical.settings
	
	static var all:[JKSplitMode] = [.free, .vertical, .horizontal, .diagonalLeft, .diagonalRight]
	
	var label: String { get {
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
	
	var icon: String { get {
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

	var settings: JKSplitSettings { get {
		switch self {
		case .free:
			return JKSplitMode.freeSettings
		case .horizontal:
			return JKSplitSettings(angle: 0)
		case .vertical:
			return JKSplitSettings(angle: CGFloat.pi / 2)
		case .diagonalLeft:
			return JKSplitSettings(angle: 3 * CGFloat.pi / 4)
		case .diagonalRight:
			return JKSplitSettings(angle: CGFloat.pi / 4)
		}
		}}
}
