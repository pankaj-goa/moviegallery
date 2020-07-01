//
//  String+.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 28/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit

extension String{
    func changeDateFormat(from: String, to: String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = from
        if let cDate = dateFormatter.date(from: self){
            dateFormatter.dateFormat = to
            return dateFormatter.string(from: cDate)
        } else{
            return nil
        }
    }
}
