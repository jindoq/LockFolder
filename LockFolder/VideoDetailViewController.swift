//
//  VideoDetailViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 6/3/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit
import DKImagePickerController
import AVKit
import AVFoundation
import CoreData
import Photos
import PopupDialog
import GoogleMobileAds
import AudioToolbox
import RSLoadingView
import RealmSwift

private var reuseIdentifier = "Cell"

class VideoDetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate{
    
    var adMobBannerView = GADBannerView()
    
    @IBOutlet var videoCollectionView: UICollectionView!
    fileprivate let sectionInsets = UIEdgeInsets(top: 11.0, left: 11.0, bottom: 11.0, right: 11.0)
    fileprivate let itemsPerRow: CGFloat = 4
    
    var albumId: String = ""
    var videos = [Video]()
    
    @IBOutlet weak var navigationTitleBar: UINavigationItem!
    
    var titleNavigation: String!
    
    var delegate: VideoDataDelegate?
    
    var indexRow: Int = 0
    
    fileprivate var arrIndex = [Int]()
    
    var selecting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initAdMobBanner()
        navigationItem.title = titleNavigation
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        showNavigationBar()
        
        let result = RealmDatabase.sharedInstance.getVideo(albumId: self.albumId)
        
        if result.count > 0 {
            for tmp in result {
                videos.append(tmp)
            }
        }
        
        self.videoCollectionView.delegate = self
        self.videoCollectionView.dataSource = self

    }
    
    func showNavigationBar(){
        
        let rightPickBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(addVideoAction))
        let rightSelectBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_select"), style: .plain, target: self, action: #selector(selectVideoAction))
        
        self.navigationItem.setRightBarButtonItems([rightSelectBarButtonItem, rightPickBarButtonItem], animated: false)
    }
    
    @objc func deleteTapped() {
        
    }
    
    @objc func shareTapped() {

    }
    
    @IBAction func addVideoAction(_ sender: UIBarButtonItem) {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allVideos
        pickerController.sourceType = .photo
        pickerController.showsCancelButton = true
        pickerController.didSelectAssets = {[unowned self] (assets: [DKAsset]) in
            let loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
            loadingView.showOnKeyWindow()
            var count = assets.count
            
            for asset in assets {
                asset.writeAVToFile(Utils.getFilePath(type: .video), presetName: "", completeBlock: { (success, filePath) in
                    if success {
                        DispatchQueue.main.async {
                            let newVideo = Video()
                            newVideo.albumId = self.albumId
                            newVideo.filePath = (filePath as NSString).lastPathComponent
                            self.videos.append(newVideo)
                            RealmDatabase.sharedInstance.saveVideo(with: newVideo)
                        }
                    }
                    
                    count -= 1
                    
                    if count <= 0 {
                        DispatchQueue.main.async {
                            let album = RealmDatabase.sharedInstance.getVideoAlbum(albumId: self.albumId)[0]
                            
                            do {
                                let realm = try Realm()
                                try! realm.write {
                                    album.number = self.videos.count
                                    //album.filePath = (self.videos[0].filePath as NSString).lastPathComponent
                                }
                                
                            } catch let error as NSError {
                                fatalError(error.localizedDescription)
                            }
                            
                            self.videoCollectionView.reloadData()
                            RSLoadingView.hideFromKeyWindow()
                        }
                        
                    }
                    
                })
            }
        }
        self.present(pickerController, animated: true) {}
    }
    
    
    // MARK: Collection Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VideoCollectionViewCell
        
        

            
//            let temp = secondsToHoursMinutesSeconds(seconds: CMTimeGetSeconds(duration))
//            let hour =  {(temp: Int) -> String in
//                if temp < 10 {
//                    return "0\(temp)"
//                }
//                return "\(temp)"
//            }
//            let h = hour(temp.0)
//            let m = hour(temp.1)
//            let s = hour(temp.2)
//            cell.durationLabel.text = "\(h):\(m):\(s)"
//            
//            let assetImageGenerator = AVAssetImageGenerator(asset: assetAV)
//            assetImageGenerator.appliesPreferredTrackTransform = true
//            var time = duration
//            time.value = min(time.value, 2)
//            do {
//                let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
//                cell.imagePreview.image = UIImage(cgImage: imageRef)
//            } catch {
//                print("*************Error image: \(error)")
//            }
        
        
        return cell
    }
    
    func secondsToHoursMinutesSeconds (seconds : Double) -> (Int, Int, Int) {
        let temp : Int = Int(round(seconds))
        return (temp / 3600, (temp % 3600) / 60, (temp % 3600) % 60)
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
        
       //play video
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        guard selecting else {
            return
        }
        
        videoCollectionView?.allowsMultipleSelection = true
        videoCollectionView?.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
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
    
    func playVideo( url: URL) {
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true) {
            player.play()
        }
    }
    
    // MARK: Helper function
    
    @IBAction func selectVideoAction(_ sender: UIBarButtonItem) {
        selecting = true
        arrIndex.removeAll(keepingCapacity: false)
        
        let rightDeleteBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteTapped))
        
        let rightShareBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(shareTapped))
        
        let leftCancelBarButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(cancelTapped))
        
        self.navigationItem.setRightBarButtonItems([rightDeleteBarButtonItem, rightShareBarButtonItem], animated: false)
        
        self.navigationItem.setLeftBarButtonItems([leftCancelBarButtonItem], animated: false)
    }
    
    @objc func cancelTapped() {
        selecting = false
        
        self.navigationItem.setLeftBarButtonItems(nil, animated: false)
        
        let rightPickBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(addVideoAction))
        
        let rightSelectBarButtonItem:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_select"), style: .plain, target: self, action: #selector(selectVideoAction))
        self.navigationItem.setRightBarButtonItems([rightSelectBarButtonItem, rightPickBarButtonItem], animated: false)
        
        videoCollectionView?.reloadData()
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
