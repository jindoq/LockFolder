//
//  VideoTableViewCell.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/31/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var numberVideo: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photo.layer.cornerRadius = photo.bounds.height / 2
        photo.clipsToBounds = true
        photo.contentMode = .scaleAspectFill
    }
}
