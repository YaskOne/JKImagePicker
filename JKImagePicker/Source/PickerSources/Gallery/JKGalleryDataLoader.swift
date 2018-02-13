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
	public var thumbnail: UIImage? = nil
	public var fullSize: UIImage? = nil
	
	public init(asset: PHAsset) {
		self.asset = asset
	}
}


public class JKAlbumAsset {
	public var name:String { get { return collection.localizedTitle ?? "Untitled"}}
	public var count:Int { get { return collection.estimatedAssetCount} }
	
	public let collection:PHAssetCollection
	
	public var photoAssets = [JKPhotoAsset]()
	
	public init(collection:PHAssetCollection) {
		self.collection = collection
	}
}

public class JKGalleryDataLoader {
    
    public var albums = [JKAlbumAsset]()
	
	public var photos = [JKPhotoAsset]()
	
	
    public func fetchAllPhotos() {
        fetchAlbums()
        
        for album in albums {
            fetchPhotoAssets(in: album)
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
        
    public func fetchAlbums() {
        let options = PHFetchOptions()
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: options)

        userAlbums.enumerateObjects{ (object: AnyObject, count: Int, stop: UnsafeMutablePointer) in
            if let collection  = object as? PHAssetCollection {

                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

				let newAlbum = JKAlbumAsset(collection: collection)
                self.albums.append(newAlbum)
            }
        }
    }
    
    public func fetchPhotoAssets(in album: JKAlbumAsset) {
		
        let photoAssets = PHAsset.fetchAssets(in: album.collection, options: nil)

		photoAssets.enumerateObjects{(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if let asset = object as? PHAsset {
                let photoAsset = JKPhotoAsset(asset: asset)
				self.photos.append(photoAsset)
				album.photoAssets.append(photoAsset)
            }
        }
    }
	
	public static func loadImageForAsset(asset: JKPhotoAsset) {
		let imageManager = PHImageManager.default()
		
		/* For faster performance, and maybe degraded image */
		let options = PHImageRequestOptions()
		options.deliveryMode = .fastFormat
		options.isSynchronous = true
		
		let imageSize = CGSize(width: asset.asset.pixelWidth,
							   height: asset.asset.pixelHeight)

		imageManager.requestImage(for: asset.asset,
								  targetSize: imageSize,
								  contentMode: .aspectFill,
								  options: options,
								  resultHandler: {
									(image, info) -> Void in
									
									if let photo = image {
										asset.fullSize = photo
									}
		})
	}
	
	public static func loadThumbnailForAsset(asset: JKPhotoAsset, imageSize: CGSize) {
		let imageManager = PHImageManager.default()
		
		/* For faster performance, and maybe degraded image */
		let options = PHImageRequestOptions()
		options.deliveryMode = .fastFormat
		options.isSynchronous = true
		
		imageManager.requestImage(for: asset.asset,
								  targetSize: imageSize,
								  contentMode: .aspectFill,
								  options: options,
								  resultHandler: {
									(image, info) -> Void in
									
									if let photo = image {
										asset.thumbnail = photo
									}
		})
	}

}

public extension PHAsset {
    func isPortrait() -> Bool {
        return self.pixelWidth < self.pixelHeight
    }
}

