//
//  SearchBar+.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 25/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit

/// Extension for UISearchBar
extension UISearchBar{
    /**
    This function will check if SearchBar contains text or not and to be called on UISearchBar.
    - Returns:
     - Boolean variable true if empty else false
    ### Usage Example: ###
    ````
    self.searchBar.isEmpty()
     
    ````
    */
    func isEmpty() -> Bool{
        return self.text == nil || self.text == ""
    }
    
    /**
    This property will check for searchbar textfield for iOS version 13.0 or other on UISearchBar.
    - Returns:
     - Optional textfield of the search bar
    ### Usage Example: ###
    ````
    self.searchBar.textField
     
    ````
    */
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
