//
//  Utils.swift
//  LockFolder
//
//  Created by DuyTu-Kakashi on 8/26/17.
//  Copyright © 2017 tranduytu. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

class Utils {
    static func shareImage(viewController: UIViewController, images: [UIImage]) {
        
        let shareScreen = UIActivityViewController(activityItems: images, applicationActivities: nil)
        let popoverPresentationController = shareScreen.popoverPresentationController
        popoverPresentationController?.permittedArrowDirections = .any
        
        viewController.present(shareScreen, animated: true, completion: nil)
    }
    
    static func showPopup(viewController: UIViewController, message: String, title: String) {
        let title = title
        let message = message
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message)
        
        // Create buttons
        let buttonOne = CancelButton(title: "OK") {
        }
        
        popup.addButtons([buttonOne])
        
        viewController.present(popup, animated: true, completion: nil)
    }
    
    static func getFolderPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    }
    
    static func getFilePath(type: FileType) -> String {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

        
        var ext = "png"
        if type == .video {
            ext = "mp4"
        }
        
        var uuid = UUID().uuidString
        var fileName = "\(uuid).\(ext)"
        var filePath = (dirPath as NSString).appendingPathComponent(fileName)
        
        while FileManager.default.fileExists(atPath: filePath) {
            uuid = UUID().uuidString
            fileName = "\(uuid).\(ext)"
            filePath = (dirPath as NSString).appendingPathComponent(fileName)
        }
        
        return filePath
    }
}
