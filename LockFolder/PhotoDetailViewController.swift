//
//  PhotoDetailViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 6/3/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit
import DKImagePickerController
import CoreData
import PopupDialog
import GoogleMobileAds
import AudioToolbox
import RSLoadingView
import RealmSwift

private let reuseIdentifier = "PhotoCell"

class PhotoDetailViewController: UIViewController, UICollectionViewDelegateFlowLayout, SlideShowDelegate, UICollectionViewDataSource, UICollectionViewDelegate, GADBannerViewDelegate {
    
    var adMobBannerView = GADBannerView()
    
    // MARK: - Properties
    
    var delegate: PhotoDataDelegate?
    
    var titleNavigation: String!
    var albumId: String = ""
    var photos = [Photo]()
    
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet var previewView: UICollectionView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 11.0, left: 11.0, bottom: 11.0, right: 11.0)
    fileprivate let itemsPerRow: CGFloat = 4
    
    fileprivate var arrIndex = [Int]()
    
    var selecting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initAdMobBanner()
 
        
        navigationItem.title = titleNavigation
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        self.showNavigationBar()
        
        let result = RealmDatabase.sharedInstance.getPhoto(albumId: self.albumId)
        
        if result.count > 0 {
            for tmp in result {
                photos.append(tmp)
            }
        }
        
        self.previewView.delegate = self
        self.previewView.dataSource = self
        
    }
    
    func showNavigationBar(){
        
        let rightPickBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(addPhotoAction))
        let rightSelectBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_select"), style: .plain, target: self, action: #selector(selectPhotoAction))
        
        self.navigationItem.setRightBarButtonItems([rightSelectBarButtonItem, rightPickBarButtonItem], animated: false)
    }
    
    
    func updateImageDelete(index: Int) {
        self.photos.remove(at: index)
        let album = RealmDatabase.sharedInstance.getAlbum(albumId: self.albumId)[0]
        
        do {
            let realm = try Realm()
            try! realm.write {
                album.number = self.photos.count
                album.filePath = self.photos.count == 0 ? nil : (self.photos[0].filePath as NSString).lastPathComponent
            }
            
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        previewView.reloadData()
    }
    
    @IBAction func selectPhotoAction(_ sender: UIBarButtonItem) {
        selecting = true
        arrIndex.removeAll()
        
        let rightDeleteBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteTapped))
        
        let rightShareBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(shareTapped))
        
        let leftCancelBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_cancel"), style: .plain, target: self, action: #selector(cancelTapped))
        
        self.navigationItem.setRightBarButtonItems([rightDeleteBarButtonItem, rightShareBarButtonItem], animated: false)
        
        self.navigationItem.setLeftBarButtonItems([leftCancelBarButtonItem], animated: false)
    }
    
    @objc func deleteTapped() {
        
        guard self.arrIndex.count > 0 else {
            Utils.showPopup(viewController: self, message: "No photo was selected", title: "NOTICE")
            return
        }
        
        let title = "WARNING"
        let message = "Are you sure to delete"
        let popup = PopupDialog(title: title, message: message)
        let buttonOne = CancelButton(title: "CANCEL") {
        }
        
        let buttonTwo = DefaultButton(title: "OK") {
            let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
            loadingView.showOnKeyWindow()
            
            self.arrIndex = self.arrIndex.sorted()
            self.arrIndex.reverse()
            for i in self.arrIndex {
                do {
                    let photo = self.photos[i]
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
                self.photos.remove(at: i)
            }
            let album = RealmDatabase.sharedInstance.getAlbum(albumId: self.albumId)[0]
            
            do {
                let realm = try Realm()
                try! realm.write {
                    album.number = self.photos.count
                    album.filePath = self.photos.count == 0 ? nil : (self.photos[0].filePath as NSString).lastPathComponent
                }
                
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
            self.arrIndex.removeAll()
            self.previewView.reloadData()
            RSLoadingView.hideFromKeyWindow()
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    
    @objc func shareTapped() {
        guard self.arrIndex.count > 0 else {
            Utils.showPopup(viewController: self, message: "No photo was selected", title: "NOTICE")
            return
        }
        var images = [UIImage]()
        for i in self.arrIndex {
            let photo = self.photos[i]
            images.append(UIImage(contentsOfFile: (Utils.getFolderPath() as NSString).appendingPathComponent(photo.filePath))!)
        }

        Utils.shareImage(viewController: self, images: images)
    }
    
    @objc func cancelTapped() {
        selecting = false
        
        self.navigationItem.setLeftBarButtonItems(nil, animated: false)
        let rightPickBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(addPhotoAction))
        
        let rightSelectBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_select"), style: .plain, target: self, action: #selector(selectPhotoAction))
        self.navigationItem.setRightBarButtonItems([rightSelectBarButtonItem, rightPickBarButtonItem], animated: false)
        
        previewView?.reloadData()
    }
    
    @IBAction func addPhotoAction(_ sender: UIBarButtonItem) {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.sourceType = .photo
        pickerController.showsCancelButton = true
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            
            let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
            loadingView.showOnKeyWindow()
            var count = assets.count
            
            for asset in assets {
                asset.writeImageToFile(Utils.getFilePath(type: .image), completeBlock: { (success, filePath) in
                    if success {
                        DispatchQueue.main.async {
                        let newPhoto = Photo()
                        newPhoto.albumId = self.albumId
                        newPhoto.filePath = (filePath as NSString).lastPathComponent
                        self.photos.append(newPhoto)
                        RealmDatabase.sharedInstance.savePhoto(with: newPhoto)
                        }
                    }
                    
                    count -= 1
                    
                    if count <= 0 {
                        DispatchQueue.main.async {
                            let album = RealmDatabase.sharedInstance.getAlbum(albumId: self.albumId)[0]
                            
                            do {
                                let realm = try Realm()
                                try! realm.write {
                                    album.number = self.photos.count
                                    album.filePath = (self.photos[0].filePath as NSString).lastPathComponent
                                }
                                
                            } catch let error as NSError {
                                fatalError(error.localizedDescription)
                            }
                            
                            self.previewView.reloadData()
                            RSLoadingView.hideFromKeyWindow()
                        }
 
                    }
                    
                })
            }
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionCell
        let filePath = self.photos[indexPath.row].filePath
        cell.imageView.image = UIImage(contentsOfFile: (Utils.getFolderPath() as NSString).appendingPathComponent(filePath!))
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard !selecting else {
            return true
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier :"SlideShowViewController") as! SlideShowViewController
        vc.photos = self.photos
        vc.index = indexPath.row
        vc.delegate = self
        vc.titleNavigation = self.titleNavigation
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard selecting else {
            return
        }
        
        previewView?.allowsMultipleSelection = true
        previewView?.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        arrIndex.append(indexPath.row)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        
        guard selecting else {
            return
        }
        
        
        if let index = arrIndex.index(of: indexPath.row) {
            arrIndex.remove(at: index)
        }
    }
    
    // MARK: -  ADMOB BANNER
    func initAdMobBanner() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            // iPhone
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 320, height: 50)
        } else  {
            // iPad
            adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 468, height: 60))
            adMobBannerView.frame = CGRect(x: 0, y: view.frame.size.height, width: 468, height: 60)
        }
        
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = false
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        hideBanner(adMobBannerView)
    }
    
    
}
