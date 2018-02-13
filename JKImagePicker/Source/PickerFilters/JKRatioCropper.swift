//
//  JKRatioCropper.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 07/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public class JKImageFilter {
    public func processImage(_ image: UIImage) -> UIImage {
        return image
    }
}



public class JKRatioCropper : JKImageFilter {
	
    public var ratio:CGFloat = 16/9
    
    public init(ratio: CGFloat) {
        self.ratio = ratio
    }
	
    public override func processImage(_ image: UIImage) -> UIImage {
        return image.cropToRatio(ratio)
    }
}
