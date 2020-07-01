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

extension UIViewController{
    
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
    
    func showProgressLoader(message: String = "Please wait..."){
        self.view.endEditing(true)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message)
    }
    
    func hideProgressLoader(){
        SVProgressHUD.dismiss()
    }
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
