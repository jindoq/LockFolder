//
//  PhotoCollectionCell.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/21/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageTick: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 3 : 0
            imageTick.isHidden = isSelected ? false : true
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        imageTick.layer.cornerRadius = imageTick.bounds.height/2
        imageTick.clipsToBounds = true
        imageTick.isHidden = true
        imageView.layer.borderColor = UIColor(red: 103.0/255.0, green: 184.0/255.0, blue: 203.0/255.0, alpha: 1.0).cgColor
        isSelected = false
    }
}
