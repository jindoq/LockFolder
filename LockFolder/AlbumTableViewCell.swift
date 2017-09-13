//
//  AlbumTableViewCell.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/23/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var imageAlbum: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var titleAlbum: UILabel!
    @IBOutlet weak var numberImage: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
        imageAlbum.layer.cornerRadius = imageAlbum.bounds.height / 2
        imageAlbum.clipsToBounds = true
        imageAlbum.contentMode = .scaleAspectFill
    }
}
