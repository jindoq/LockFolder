//
//  RealDatabase.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 8/22/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDatabase {
    static let sharedInstance = RealmDatabase()
    
    func savePhoto(with object: Photo ) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveVideo(with object: Video ) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func savePhotoAlbum(with object: PhotoAlbum) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getPhoto(albumId: String) -> Results<Photo> {
         do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "albumId = '\(albumId)'")
            return realm.objects(Photo.self).filter(predicate)
         } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getVideo(albumId: String) -> Results<Video> {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "albumId = '\(albumId)'")
            return realm.objects(Video.self).filter(predicate)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getAlbum(albumId: String) -> Results<PhotoAlbum> {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "iD = '\(albumId)'")
            return realm.objects(PhotoAlbum.self).filter(predicate)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getVideoAlbum(albumId: String) -> Results<VideoAlbum> {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "iD = '\(albumId)'")
            return realm.objects(VideoAlbum.self).filter(predicate)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getPhotos() -> Results<Photo> {
        do {
            let realm = try Realm()
            return realm.objects(Photo.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getPhotoAlbums() -> Results<PhotoAlbum> {
        do {
            let realm = try Realm()
            return realm.objects(PhotoAlbum.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func getVideoAlbums() -> Results<VideoAlbum> {
        do {
            let realm = try Realm()
            return realm.objects(VideoAlbum.self)
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func saveVideoAlbum(with object: VideoAlbum) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}

class Photo: Object {
    @objc dynamic var albumId: String!
    @objc dynamic var filePath: String!
}

class PhotoAlbum: Object {
    @objc dynamic var iD: String!
    @objc dynamic var name: String!
    @objc dynamic var number: Int = 0
    @objc dynamic var filePath: String!
}

class Video: Object {
    @objc dynamic var albumId: String!
    @objc dynamic var filePath: String!
}

class VideoAlbum: Object {
    @objc dynamic var iD: String!
    @objc dynamic var name: String!
    @objc dynamic var number: Int = 0
    @objc dynamic var filePath: String!
}
