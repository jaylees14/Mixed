//
//  SearchCacherTests.swift
//  MixedTests
//
//  Created by Jay Lees on 09/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import XCTest
@testable import Mixed

class SearchCacherTests: XCTestCase {

    func testAddToCache(){
        let songName = "Beat it"
        SearchCacher.cache(song: songName)
        XCTAssert(SearchCacher.getLastThree().contains(songName))
    }
}
