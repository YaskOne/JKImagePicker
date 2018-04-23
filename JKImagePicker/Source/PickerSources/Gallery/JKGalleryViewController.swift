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
    
    var galleryVC: JKGalleryCollectionViewController?
    var albumsVC: JKAlbumsCollectionViewController?

    @IBOutlet weak var galleryContainer: UIView!
    @IBOutlet weak var albumsContainer: UIView!
    
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    
    @IBOutlet weak var albumLabel: UILabel!
    
    var albumsDisplayed: Bool = true {
        didSet {
            galleryContainer.isHidden = albumsDisplayed
            albumsContainer.isHidden = !albumsDisplayed
            if albumsDisplayed {
                albumLabel.text = "Albums"
            }
        }
    }
    
    override public var availableControls: [JKCameraControlItem] { get {
			return [.free,.free,.free,.free,.free,.free,.free]
			}}
	
	public let photoLoader = JKGallery()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        topOffset?.constant = UIApplication.shared.statusBarFrame.height + 8
    }
	
	public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedCollection" {
            if let vc = segue.destination as? JKGalleryCollectionViewController {
                photoLoader.fetchAllPhotos()
                vc.delegate = self
                vc.items = photoLoader.sortedPhotos.map{ JKGalleryItem(asset:$0) }
                galleryVC = vc
            }
        }
        if segue.identifier == "EmbededAlbums" {
            if let vc = segue.destination as? JKAlbumsCollectionViewController {
                photoLoader.fetchAlbums()
                vc.delegate = self
                vc.items = photoLoader.validAlbums.map{ JKAlbumsItem(asset:$0) }
                albumsVC = vc
            }
        }
	}
	
    @IBAction func backButtonTapped(_ sender: Any) {
        if albumsDisplayed {
            self.commandButtonTapped(command: JKCameraControlItem.back.rawValue)
        }
        else {
            albumsDisplayed = true
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
            
            if let location = asset.asset.location {
                dict = ["location": location]
            }
            
            delegate?.pictureAvailable(image, metaData: dict)
        }
    }
    
}

extension JKGalleryViewController : JKAlbumsViewControllerDelegate {
    func albumSelected(_ asset: JKAlbumsItem) {
        galleryVC?.items = asset.sortedPhotos.map{ JKGalleryItem(asset:$0) }
        albumsDisplayed = false
        albumLabel.text = asset.asset.name
    }
}
