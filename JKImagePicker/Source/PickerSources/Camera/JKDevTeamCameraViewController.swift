//
//  JKDevTeamCameraViewController.swift
//  JKImagePicker
//
//  Created by Arthur Ngo Van on 07/03/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import Foundation

public class JKDevTeamCameraViewController: JKCameraViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image1: UIImage?
    var image2: UIImage?
    
    public override func viewDidLoad() {
		imageView.contentMode = .scaleAspectFill
        imageView.image = image1 ?? UIImage.init(named: "MysteryPreview")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
    }
    
    public override func viewDidLayoutSubviews() {
    }
    
    public override func switchCamera() {
    }
	
	

}
