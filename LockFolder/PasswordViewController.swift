//
//  PasswordViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 5/23/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import UIKit
import PinCodeTextField

class PasswordViewController: UIViewController {
    let MyKeychainWrapper = KeychainWrapper()
    @IBOutlet weak var pinCodeText: PinCodeTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        pinCodeText.delegate = self as PinCodeTextFieldDelegate
        pinCodeText.keyboardType = .numberPad
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension PasswordViewController: PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        if textField.text?.characters.count == 4 {
            MyKeychainWrapper.mySetObject(textField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            self.navigationController?.popToRootViewController(animated: true);
        }
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}

