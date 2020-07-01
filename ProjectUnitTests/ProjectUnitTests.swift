//
//  ProjectUnitTests.swift
//  ProjectUnitTests
//
//  Created by Pankaj Shirodkar on 28/06/20.
//  Copyright © 2020 Pankaj Shirodkar. All rights reserved.
//

import XCTest
@testable import MovieGalleryAssignment

class ProjectUnitTests: XCTestCase {

    func testGetFormattedDate(){
        let cDate = "2022-10-31"
        let formattedDate = "31.10.2022"
        let compareDate = cDate.changeDateFormat(from: "yyyy-MM-dd", to: "dd.MM.yyyy") ?? ""
        XCTAssertEqual(formattedDate, compareDate)
    }
}
