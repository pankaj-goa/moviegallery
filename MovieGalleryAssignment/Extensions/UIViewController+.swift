//
//  UIViewController+.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 24/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import TTGSnackbar

/// Extension for UIViewController
extension UIViewController{
    /**
    Call this function for loading the navigation bar in your View Controller class.
    - Parameters:
       - titleName: Pass your title name to be displayed in navigation in String.
    
    ### Usage Example: ###
    ````
    self.configureNavigationBar(titleName: "My Title")
     
    ````
    */
    func configureNavigationBar(titleName: String){
        self.navigationController?.navigationBar.isTranslucent = false
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.tintColor = UIColor.link
        } else {
            self.navigationController?.navigationBar.tintColor = UIColor.systemBlue
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationItem.title = titleName
    }
    /**
    Call this function displaying SV Progress Loader your View Controller class.
    - Parameters:
       - message: Pass your alert message in String.
    
    ### Usage Example: ###
    ````
    self.showProgressLoader(message: "Loading...")
    }
    ````
    */
    func showProgressLoader(message: String = "Please wait..."){
        self.view.endEditing(true)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message)
    }
    /**
    Call this function hiding SV Progress Loader your View Controller class.
    
    ### Usage Example: ###
    ````
    self.hideProgressLoader()
    }
    ````
    */
    func hideProgressLoader(){
        SVProgressHUD.dismiss()
    }
    /**
    Call this function for showing snack bar for a partcular time interval Controller class.
    - Parameters:
        - timeInterval: time interval for which snack bar should be visible.
        - message: Pass on the message to be displayed in the snack bar..
    ### Usage Example: ###
    ````
    self.showSnackBar(timeInterval: 1.0, message: "No internet connection")
    }
    ````
    */
    func showSnackBar(timeInterval: Double = 3, message: String){
        let snackbar = TTGSnackbar(
            message: message,
            duration: .forever
        )
        snackbar.show()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            snackbar.dismiss()
        }
    }
}
