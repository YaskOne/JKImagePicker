//
//  JackShadowButton.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 19/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

public class JKShadowButton: UIButton {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
   public  required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func setup() {
        self.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 0.6)
        self.titleLabel?.layer.shadowOpacity = 0.7
        self.titleLabel?.layer.shadowRadius = 0.5
    }
    
}
