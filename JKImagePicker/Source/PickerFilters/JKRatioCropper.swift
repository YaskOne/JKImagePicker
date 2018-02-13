//
//  JKRatioCropper.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 07/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

class JKImageFilter {
    func processImage(_ image: UIImage) -> UIImage {
        return image
    }
}



class JKRatioCropper : JKImageFilter {
	
    var ratio:CGFloat = 16/9
    
    init(ratio: CGFloat) {
        self.ratio = ratio
    }
	
    override func processImage(_ image: UIImage) -> UIImage {
        return image.cropToRatio(ratio)
    }
}
