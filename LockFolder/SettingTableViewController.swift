//
//  SettingTableViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 5/15/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var switchTouchIdButton: UISwitch!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hasTouchId = UserDefaults.standard.bool(forKey: "hasTouchId")
        
        if hasTouchId {
            switchTouchIdButton.setOn(true, animated:false)
        } else {
            switchTouchIdButton.setOn(false, animated:false)
        }
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    @IBAction func switchTouchIdAction(_ sender: Any) {
        if (sender as! UISwitch).isOn {
            UserDefaults.standard.set(true, forKey: "hasTouchId")
            UserDefaults.standard.synchronize()
        }
        else {
            UserDefaults.standard.set(false, forKey: "hasTouchId")
            UserDefaults.standard.synchronize()
        }
    }
   
    @IBAction func signOutAction(_ sender: Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
}
