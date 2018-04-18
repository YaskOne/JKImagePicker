//
//  JKAlbumsCollectionViewController.swift
//  JKImagePicker
//
//  Created by Arthur Ngo Van on 14/04/2018.
//  Copyright © 2018 Jack World. All rights reserved.
//

import UIKit

protocol JKAlbumsViewControllerDelegate {
    func albumSelected(_ asset: JKAlbumsItem)
}

struct JKAlbumsItem {
    let asset:JKAlbumAsset
    
    public var sortedPhotos: [JKPhotoAsset] {
        get {
            return asset.photoAssets.sorted(by: { (lhs, rhs) -> Bool in
                if let date1 = lhs.date, let date2 = rhs.date {
                    return date1.compare(date2).rawValue > 0
                }
                return false
            })
        }
    }
}

class JKAlbumsCollectionViewController: UITableViewController {
    
    private let reuseIdentifier = "AlbumViewCell"
    
    var delegate : JKAlbumsViewControllerDelegate?
    
    var items = [JKAlbumsItem]() { didSet {
        tableView?.reloadData()
        }}
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if let cell = cell as? JKAlbumViewCell {
            cell.item = items[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.albumSelected(items[indexPath.item])
    }

}

