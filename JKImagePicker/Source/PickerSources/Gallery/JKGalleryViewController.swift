//
//  JKGalleryPickerViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

class JKGalleryViewController: JKImagePickerSourceViewController {

	override var availableControls: [JKCameraControlItem] { get {
			return [.camera,.pad,.pad,.pad,.pad,.pad,.close]
			}}
	
	let photoLoader = JKGalleryDataLoader()
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EmbedCollection" {
			if let vc = segue.destination as? JKGalleryCollectionViewController {
				photoLoader.fetchAllPhotos()
				vc.delegate = self
				vc.items = photoLoader.photos.map{ JKGalleryItem(asset:$0) }
			}
		}
	}
	
}

extension JKGalleryViewController : JKGalleryViewControllerDelegate {
	
	func photoAssetSelected(_ asset: JKPhotoAsset) {
		
		if asset.fullSize == nil {
			JKGalleryDataLoader.loadImageForAsset(asset: asset)
		}
		if let image = asset.fullSize {
			delegate?.pictureAvailable(image)
		}
	}
	
}
