//
//  JKSplitComposition.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 09/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import CoreGraphics
import JackFoundation

public class JKSplitComposition : JKComposition {
	
	public var angle: CGFloat = 0
	public var center: CGPoint = CGPoint(x: 0.5, y: 0.5)

	public override var image: UIImage? { get {
        guard let img1 = image1?.image?.cgImage, let frame = image1?.frame else {
            return nil
        }
		let img2 = image2?.image?.cgImage
        return JKSplitView.generateSplitImage(image1: img1, image2: img2, angle: angle, center: center, frame: frame)
        }
    }

	
	public init(angle: CGFloat = 0, center: CGPoint = CGPoint(x:0.5, y:0.5)) {
		super.init()
		self.angle = angle
		self.center = center
	}
	
}
