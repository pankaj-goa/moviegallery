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
}
