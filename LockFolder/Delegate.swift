//
//  Delegate.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/22/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import Foundation
import CoreData

protocol PhotoDataDelegate {
    func updateData(data: [NSManagedObject])
}

protocol SlideShowDelegate {
    func updateImageDelete(index: Int)
}

protocol VideoDataDelegate {
    func updateData()
}
