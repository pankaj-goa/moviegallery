//
//  String+.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 28/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import UIKit
/// Extension for String
extension String{
    /**
    Call this function to change the date format called for the string.
    - Parameters:
        - from: the current format of the string date.
        - to: the current format the date should be converted to.
    - Returns:
         - Optional string of the formatted date.
    
    ### Usage Example: ###
    ````
    let dob: String = "2015-12-27"
    let formattedDate = dob.changeDateFormat(from: "yyyy-MM-dd", to: "dd.MM.yyyy")
     
    ````
    */
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
