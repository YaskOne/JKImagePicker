//
//  JKGalleryCollectionViewController.swift
//  JackImagePicker
//
//  Created by Tristan Leblanc on 06/02/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import Photos

protocol JKGalleryViewControllerDelegate {
	func photoAssetSelected(_ asset: JKPhotoAsset)
}

struct JKGalleryItem {
	let asset:JKPhotoAsset
}

class JKGalleryCollectionViewController: UICollectionViewController {
	
	private let reuseIdentifier = "GalleryItemCell"

	var delegate : JKGalleryViewControllerDelegate?
	
	var items = [JKGalleryItem]() { didSet {
		collectionView?.reloadData()
		}}
	
	var itemCellSize: CGSize { get {
		guard let viewWidth = collectionView?.bounds.width else {
			return CGSize.zero
		}
		let w = (viewWidth - CGFloat(numberOfColumns - 1) * cellsSpacing) / CGFloat(numberOfColumns)
		return CGSize(width: w, height: w * cellRatio)
		}}
	
	var numberOfColumns = 3
	
	var cellRatio: CGFloat = 16 / 9
	var cellsSpacing: CGFloat =  2
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
		if let photoCell = cell as? JKGalleryPhotoCollectionViewCell {
			photoCell.item = items[indexPath.row]
		}
    
        return cell
    }

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		delegate?.photoAssetSelected(items[indexPath.row].asset)
	}
	
}

//MARK: - Flow Layout

extension JKGalleryCollectionViewController : UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return cellsSpacing
	}

	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return itemCellSize
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return cellsSpacing
	}
	
}
