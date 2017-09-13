//
//  ViewController.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 3/18/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import LocalAuthentication
import UIKit
import PinCodeTextField

class LoginViewController: UIViewController {
    
    @IBOutlet weak var pinCode: PinCodeTextField!
    let MyKeychainWrapper = KeychainWrapper()
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    var context = LAContext()
    
    @IBOutlet weak var touchIDButton: UIButton!
    @IBOutlet weak var createInfoLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        context = LAContext()
        
        pinCode.text = ""
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        let hasTouchId = UserDefaults.standard.bool(forKey: "hasTouchId")
        
        if hasLogin {
            createInfoLabel.isHidden = true
        } else {
            createInfoLabel.isHidden = false
        }
        
        
        if hasTouchId {
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                touchIDButton.isHidden = false
                //touchIDLoginAction(touchIDButton)
            }
            else {
                touchIDButton.isHidden = true
            }
        } else {
            touchIDButton.isHidden = true
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        UIImage(named: "bg_main")?.draw(in: self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
        
        pinCode.delegate = self as PinCodeTextFieldDelegate
        pinCode.keyboardType = .numberPad
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func touchIDLoginAction(_ sender: Any) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Logging in with Touch ID") {
                                    [unowned self] (success, authenticationError) in
                                    
                                    DispatchQueue.main.async {
                                        if success {
                                            self.performSegue(withIdentifier: "dismissLogin", sender: self)
                                        }
                                        
                                        if authenticationError != nil {
                                            
                                            var message : NSString
                                            var showAlert : Bool
                                            
                                            switch(authenticationError!) {
                                            case LAError.authenticationFailed:
                                                message = "There was a problem verifying your identity."
                                                showAlert = true
                                                break;
                                            case LAError.userCancel:
                                                message = "You pressed cancel."
                                                showAlert = false
                                                break;
                                            case LAError.userFallback:
                                                message = "You pressed password."
                                                showAlert = false
                                                break;
                                            default:
                                                showAlert = true
                                                message = "Touch ID may not be configured"
                                                break;
                                            }
                                            
                                            let alertView = UIAlertController(title: "Error",
                                                                              message: message as String, preferredStyle:.alert)
                                            let okAction = UIAlertAction(title: "Done!", style: .default, handler: nil)
                                            alertView.addAction(okAction)
                                            if showAlert {
                                                self.present(alertView, animated: true, completion: nil)
                                            }
                                            
                                        }
                                    }
                                    
            }
        } else {
            let alertView = UIAlertController(title: "Error",
                                              message: "Touch ID not available" as String, preferredStyle:.alert)
            let okAction = UIAlertAction(title: "Done!", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func checkLogin(password: String ) -> Bool {
        if password == MyKeychainWrapper.myObject(forKey: "v_Data") as? String {
            return true
        } else {
            return false
        }
    }
}
extension LoginViewController: PinCodeTextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        if textField.text?.characters.count == 4 {
            textField.resignFirstResponder()
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                MyKeychainWrapper.mySetObject(textField.text, forKey:kSecValueData)
                MyKeychainWrapper.writeToKeychain()
                UserDefaults.standard.set(true, forKey: "hasLoginKey")
                UserDefaults.standard.synchronize()
                
                performSegue(withIdentifier: "dismissLogin", sender: self)
            } else {
                if checkLogin(password: textField.text!) {
                    performSegue(withIdentifier: "dismissLogin", sender: self)
                } else {
                    let alertView = UIAlertController(title: "Login Problem",
                                                      message: "Wrong password." as String, preferredStyle:.alert)
                    let okAction = UIAlertAction(title: "Try Again!", style: .default, handler: nil)
                    alertView.addAction(okAction)
                    pinCode.text = ""
                    self.present(alertView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}


