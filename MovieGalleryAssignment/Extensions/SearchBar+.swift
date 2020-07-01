//
//  SearchBar+.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 25/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit

extension UISearchBar{
    func isEmpty() -> Bool{
        return self.text == nil || self.text == ""
    }
    
    var textField : UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            for view : UIView in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
