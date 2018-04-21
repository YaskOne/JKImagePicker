//
//  JKAlbumViewCellCollectionViewCell.swift
//  JKImagePicker
//
//  Created by Arthur Ngo Van on 14/04/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

class JKAlbumViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbImage: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    var item: JKAlbumsItem? { didSet {
        update()
        }}
    
    func update() {
        guard let item = self.item else { return }
        
        titleLabel.text = item.asset.name
        countLabel.text = String(item.sortedPhotos.count)
        if let asset = item.asset.photoAssets.first {
            JKGallery.loadThumbnailForAsset(asset: asset, imageSize: bounds.size, imageView: thumbImage)
        }
    }
    
}
