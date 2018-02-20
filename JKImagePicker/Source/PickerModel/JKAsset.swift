//
//  GalleryDataFetcher.swift
//  JackImagePicker
//
//  Created by Arthur Ngo Van on 26/01/2018.
//  Copyright © 2018 Arthur Ngo Van. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

public class JKPhotoAsset {
	
	public var asset: PHAsset
	public var location: CLLocation? { get { return asset.location } }
	public var date: Date? { get { return asset.creationDate } }
	public var thumbnail: UIImage? = nil
	public var fullSize: UIImage? = nil
	
	public init(asset: PHAsset) {
		self.asset = asset
	}
}


public class JKAlbumAsset {
	public var name:String { get { return collection.localizedTitle ?? "Untitled"}}
	public var count:Int { get { return collection.estimatedAssetCount} }
	public var date: Date? { get { return collection.startDate } }
	
	public let collection:PHAssetCollection
	
	public var photoAssets = [JKPhotoAsset]()
	
	public init(collection:PHAssetCollection) {
		self.collection = collection
	}
}


public extension PHAsset {
	func isPortrait() -> Bool {
		return self.pixelWidth < self.pixelHeight
	}
}

