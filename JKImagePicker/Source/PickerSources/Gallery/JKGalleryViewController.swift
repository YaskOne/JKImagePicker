//
//  JKGalleryPickerViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import JackFoundation

public class JKGalleryViewController: JKImagePickerSourceViewController {

	override public var availableControls: [JKCameraControlItem] { get {
			return [.back,.free,.free,.free,.free,.free,.free]
			}}
	
	public let photoLoader = JKGallery()
	
	public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EmbedCollection" {
			if let vc = segue.destination as? JKGalleryCollectionViewController {
				photoLoader.fetchAllPhotos()
				vc.delegate = self
				vc.items = photoLoader.sortedPhotos.map{ JKGalleryItem(asset:$0) }
			}
		}
	}
	
}

extension JKGalleryViewController : JKGalleryViewControllerDelegate {
	
	public func photoAssetSelected(_ asset: JKPhotoAsset) {
		if asset.fullSize == nil {
			JKGallery.loadImageForAsset(asset: asset)
		}
		if let image = asset.fullSize {
            var dict: JsonDict? = nil

            if let location = asset.location {
                dict = ["location": location]
            }
            
			delegate?.pictureAvailable(image, metaData: dict)
		}
	}
	
}
