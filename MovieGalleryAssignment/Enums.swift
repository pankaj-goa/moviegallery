//
//  Enums.swift
//  MovieGalleryAssignment
//
//  Created by Pankaj Shirodkar on 01/07/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import Foundation

///API Errors: Defined enum for  to provide  server errors
enum APIErrors: Error {
    case serverError
    var errorStr: String {
        switch self {
        default:
            return "Server error, please try after a while"
        }
    }
}

///PageError: Defined enum to provide error messages related to pagination
enum PageError: Error {
    case pageTop
    case pageBottom
    case offlineData
    case offline
    var msg: String {
        switch self {
        case .pageTop:
            return "Sorry! No earlier records are available. Pull to reload page"
        case .pageBottom:
            return "Sorry! No further records are available."
        case .offlineData:
            return "Displaying Offline Data, Pull To Reload"
        case .offline:
            return "No Internet Connection, Pull To Reload"
        }
    }
}
