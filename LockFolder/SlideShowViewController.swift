//
//  SlideShowViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/27/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit
import ImageSlideshow
import PopupDialog
import RSLoadingView
import RealmSwift

class SlideShowViewController: UIViewController {
    
    @IBOutlet var slideshow: ImageSlideshow!
    
    var photos: [Photo]!
    
    var delegate: SlideShowDelegate?
    var localSource = [ImageSource]()
    var index: Int = 0
    var currentPage: Int = -1
    var noImage = false
    var titleNavigation: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = titleNavigation
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        for photo  in self.photos {
            localSource.append(ImageSource(image: UIImage(contentsOfFile: (Utils.getFolderPath() as NSString).appendingPathComponent(photo.filePath))!))
        }
        
        slideshow.currentPage = index
        slideshow.backgroundColor = UIColor.white
        slideshow.pageControlPosition = PageControlPosition.underScrollView
        slideshow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        slideshow.pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.currentPageChanged = { page in
            self.currentPage = page
        }
        
        slideshow.setImageInputs(localSource)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        slideshow.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func didTap() {
        guard !noImage else {
            return
        }
        
        slideshow.presentFullScreenController(from: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        
        guard localSource.count > 0 else {
            showPopupNotice()
            return
        }
        
        if currentPage < 0 {
            currentPage = 0
        }
        
        if localSource.count == 1 {
            currentPage = 0
        }
        
        if currentPage >= localSource.count {
            currentPage = localSource.count - 1
        }
        
        let title = "WARNING"
        let message = "Are you sure to delete"
        let popup = PopupDialog(title: title, message: message)
        let buttonOne = CancelButton(title: "CANCEL") {
        }
        
        let buttonTwo = DefaultButton(title: "OK") {
            let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
            loadingView.showOnKeyWindow()
            
            do {
                let photo = self.photos[self.currentPage]
                if FileManager.default.fileExists(atPath: (Utils.getFolderPath() as NSString).appendingPathComponent(photo.filePath)) {
                    try FileManager.default.removeItem(atPath: (Utils.getFolderPath() as NSString).appendingPathComponent(photo.filePath))
                }
                let realm = try Realm()
                try! realm.write {
                    realm.delete(photo)
                }
                
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
            
            self.photos.remove(at: self.currentPage)
            self.localSource.remove(at: self.currentPage)
            self.delegate?.updateImageDelete(index: self.currentPage)
            self.slideshow.setImageInputs(self.localSource)
            RSLoadingView.hideFromKeyWindow()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func showPopupNotice() {
        let title = "NOTICE"
        let message = "There is no photo"
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message)
        
        // Create buttons
        let buttonOne = CancelButton(title: "OK") {
        }
        
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        
        guard localSource.count > 0 else {
            showPopupNotice()
            return
        }
        
        if currentPage < 0 {
            currentPage = 0
        }
        
        if localSource.count == 1 {
            currentPage = 0
        }
        
        if currentPage >= localSource.count {
            currentPage = localSource.count - 1
        }
        
        var images = [UIImage]()
        let photo = self.photos[self.currentPage]
        images.append(UIImage(contentsOfFile: (Utils.getFolderPath() as NSString).appendingPathComponent(photo.filePath))!)
        
        Utils.shareImage(viewController: self, images: images)
        
        
    }
    
}
