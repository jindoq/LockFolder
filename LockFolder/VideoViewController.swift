//
//  VideoViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/19/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit
import CoreData
import DKImagePickerController
import GoogleMobileAds
import AudioToolbox
import RealmSwift

class VideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, VideoDataDelegate, GADBannerViewDelegate {
    
    var adMobBannerView = GADBannerView()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet var tableView: UITableView!
    var enterNameAction: UIAlertAction? = nil
    var albumnameTextField: UITextField?
    
    var albums = [VideoAlbum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //initAdMobBanner()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let list = RealmDatabase.sharedInstance.getVideoAlbums()
        self.albums.removeAll()
        
        if list.count > 0 {
            for i in 0..<list.count {
                self.albums.append(list[i])
            }
        }
        self.tableView.reloadData()
        
    }
    
    func updateData(){
        tableView.reloadData()
    }
    
    
    @objc func textFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty == true {
                enterNameAction!.isEnabled = false
            }
            else {
                enterNameAction!.isEnabled = true
            }
        }
        else {
            enterNameAction!.isEnabled = false
        }
    }
    
    @IBAction func addVideoAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: "New Album",
            message: "Enter the name for this album",
            preferredStyle: UIAlertControllerStyle.alert)
        
        enterNameAction = UIAlertAction(
        title: "Save", style: UIAlertActionStyle.default) {
            (action) -> Void in
            
            let album = VideoAlbum()
            album.iD = UUID().uuidString
            album.name = self.albumnameTextField!.text!
            RealmDatabase.sharedInstance.saveVideoAlbum(with: album)
            
            self.albums.append(album)
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier :"VideoDetailViewController") as! VideoDetailViewController
            vc.titleNavigation = self.albumnameTextField?.text
            vc.delegate = self
            //vc.albumId = self.albums[self.albums.count - 1].iD
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel ) {
            (action) -> Void in
            
        }
        
        alertController.addTextField {
            (txtAlbumname) -> Void in
            
            self.albumnameTextField = txtAlbumname
            self.albumnameTextField!.placeholder = "<Album name>"
        }
        albumnameTextField?.addTarget(self, action: #selector(textFieldDidChange(textField:)),
                                      for: UIControlEvents.editingChanged)
        enterNameAction!.isEnabled = false
        alertController.addAction(enterNameAction!)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    // Load data to cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableCell", for: indexPath as IndexPath) as! VideoTableViewCell
        
        if self.albums[indexPath.row].number == 0 {
            cell.photo.image = UIImage(contentsOfFile: Bundle.main.path(forResource: "novideo", ofType: "jpg")!)
        } else {
            let filePath =  self.albums[indexPath.row].filePath
            cell.photo.image = UIImage(contentsOfFile: (Utils.getFolderPath() as NSString).appendingPathComponent(filePath!))
        }
        
        cell.title.text = self.albums[indexPath.row].name
        cell.numberVideo.text = "videos: \(self.albums[indexPath.row].number)"
        cell.editButton.addTarget(self, action: #selector(editCellTableAction(_:)), for: UIControlEvents.touchUpInside)
        cell.editButton.tag = indexPath.row
        return cell
    }
    
    var enterNameActionEdit: UIAlertAction? = nil
    @objc func textFieldDidChangeEdit(textField: UITextField) {
        if let text = textField.text {
            if text.isEmpty == true {
                enterNameActionEdit!.isEnabled = false
            }
            else {
                enterNameActionEdit!.isEnabled = true
            }
        }
        else {
            enterNameActionEdit!.isEnabled = false
        }
    }
    
    @IBAction func editCellTableAction(_ sender: UIButton) {
    
        let album = self.albums[sender.tag]
        let titleCell = album.name
        
        var albumnameTextFieldEdit: UITextField?
        
        let alertController = UIAlertController(
            title: "Rename Album",
            message: "Enter the name for this album",
            preferredStyle: UIAlertControllerStyle.alert)
        
        enterNameActionEdit = UIAlertAction(
        title: "Save", style: UIAlertActionStyle.default) {
            (action) -> Void in
            do {
                let realm = try Realm()
                try! realm.write {
                    album.name = albumnameTextFieldEdit!.text!
                }
                
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
            
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel ) {
            (action) -> Void in
            
        }
        
        alertController.addTextField {
            (txtAlbumname) -> Void in
            
            albumnameTextFieldEdit = txtAlbumname
            albumnameTextFieldEdit?.text = titleCell
        }
        albumnameTextFieldEdit?.addTarget(self, action: #selector(textFieldDidChangeEdit(textField:)),
                                          for: UIControlEvents.editingChanged)
        enterNameActionEdit!.isEnabled = true
        alertController.addAction(enterNameActionEdit!)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let album = self.albums[indexPath.row]
            
            // Delete photos
            let result = RealmDatabase.sharedInstance.getVideo(albumId: album.iD)
            if result.count > 0 {
                for tmp in result {
                    
                    do {
                        if FileManager.default.fileExists(atPath: (Utils.getFolderPath() as NSString).appendingPathComponent(tmp.filePath)) {
                            try FileManager.default.removeItem(atPath: (Utils.getFolderPath() as NSString).appendingPathComponent(tmp.filePath))
                        }
                        let realm = try Realm()
                        try! realm.write {
                            realm.delete(tmp)
                        }
                        
                    } catch let error as NSError {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            
            // Delete album
            do {
                let realm = try Realm()
                try! realm.write {
                    realm.delete(album)
                }
                
            } catch let error as NSError {
                fatalError(error.localizedDescription)
            }
            
            self.albums.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            break
        default:
            break
        }
    }
    
    // Select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier :"VideoDetailViewController") as! VideoDetailViewController
        let album = self.albums[indexPath.row]
        vc.titleNavigation = album.name
        vc.delegate = self
        vc.albumId = album.iD
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.pushViewController(vc, animated: true)
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
