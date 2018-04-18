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

public class JKGallery {
    
    public var albums = [JKAlbumAsset]()
    
    public var validAlbums: [JKAlbumAsset] {
        return albums.filter{$0.photoAssets.count > 0}
    }
    
    public var sortedAlbums: [JKAlbumAsset] {
        get {
            return albums.sorted(by: { (lhs, rhs) -> Bool in
                if let date1 = lhs.date, let date2 = rhs.date {
                    return date1.compare(date2).rawValue > 0
                }
                return false
            })
        }
    }
	
	public var photos = [JKPhotoAsset]()
    
    public var sortedPhotos: [JKPhotoAsset] {
        get {
            return photos.sorted(by: { (lhs, rhs) -> Bool in
                if let date1 = lhs.date, let date2 = rhs.date {
                    return date1.compare(date2).rawValue > 0
                }
                return false
            })
        }
    }
    
//    public var sortedAlbums: [JKAlbumAsset] {
//        get {
//            return photos.sorted(by: { (lhs, rhs) -> Bool in
//                return lhs.
//            })
//        }
//    }
	
	
    // MARK: - Assets Loading
	
	public func fetchAllPhotos() {
		fetchAlbums()
		
		for album in albums {
			fetchPhotoAssets(in: album)
		}
		
	}
	
    public func fetchAlbums() {
        print("FOUND")
        let options = PHFetchOptions()
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: options)

        userAlbums.enumerateObjects{ (object: AnyObject, count: Int, stop: UnsafeMutablePointer) in
            if let collection = object as? PHAssetCollection {
//PHAssetCollectionType.smartAlbum
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

                print("FOUND \(collection.assetCollectionType.rawValue) : \(collection.estimatedAssetCount)")
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
	
	//MARK: - Image Data Loading
	
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
	
    public static func loadThumbnailForAsset(asset: JKPhotoAsset, imageSize: CGSize, imageView: UIImageView? = nil) {
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
									
                                    guard let photo = image else {
                                        return
                                    }
                                    if photo.size.height > photo.size.width {
                                        asset.thumbnail = photo
                                    }
                                    else {
                                        asset.thumbnail = photo.rotatedBy(angle: CGFloat.pi / 2)
                                    }
                                    imageView?.image = asset.thumbnail
		})
	}

	//MARK: - Static Utilities
	
	static public func saveImageAsAsset(image: UIImage,location: CLLocation? = nil, failure: (()->Void)? = nil, success: @escaping (Date,String)->Void) {
		var assetChangeRequest: PHAssetChangeRequest?
		var placeholder:PHObjectPlaceholder?
		let date = Date()
		var identifier = ""
		
		JKImagePicker.checkGalleryAuthorization(error: {
			failure?()
		}, success: {
			DispatchQueue.main.async {
				PHPhotoLibrary.shared().performChanges({
					assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
					
					if let loc = location {
						assetChangeRequest?.location = loc
					}
					
					assetChangeRequest?.creationDate = date
					placeholder = assetChangeRequest?.placeholderForCreatedAsset
					identifier = placeholder?.localIdentifier ?? ""
				}, completionHandler: { successed, error in
					if successed {
						success(date,identifier)
					}
					else {
						failure?()
					}
				})
			}
		})
	}
	
	public static func checkAuthorization(error: (() -> Void)? = nil, success: @escaping() -> Void) {
		PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus)in
			switch status {
			case .denied:
				error?()
				return
			case .authorized:
				success()
				return
			default:
				error?()
				return
			}
		})
	}
}

extension UIImage {
	public func saveToGallery(location: CLLocation? = nil, failure: (()->Void)? = nil, success: @escaping (Date,String)->Void) {
		JKGallery.saveImageAsAsset(image: self, location: location, failure: failure, success: success)
	}
}
