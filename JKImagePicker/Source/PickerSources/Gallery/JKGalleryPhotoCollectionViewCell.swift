//
//  JKGalleryPhotoCollectionViewCell.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit

class JKGalleryPhotoCollectionViewCell: UICollectionViewCell {
	@IBOutlet var imageView: UIImageView!
	
	var item: JKGalleryItem? { didSet {
		update()
		}}
	
	func update() {
		guard let item = self.item else { return }
		if let image = item.asset.thumbnail {
			imageView.image = image
			return
		}

		JKGalleryDataLoader.loadThumbnailForAsset(asset: item.asset, imageSize: bounds.size)
		imageView.image = item.asset.thumbnail
	}
}
