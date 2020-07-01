//
//  SnackAlerts.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 28/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import Foundation

enum SnackAlert: Error {
    case pageTop
    case pageBottom
    var msg: String {
        switch self {
        case .pageTop:
            return "Sorry! No earlier records are available."
        case .pageBottom:
            return "Sorry! No further records are available."
        }
    }
}
