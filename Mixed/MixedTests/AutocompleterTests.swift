//
//  AutocompleterTests.swift
//  MixedTests
//
//  Created by Jay Lees on 09/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import XCTest
@testable import Mixed

class AutocompleterTests: XCTestCase {
    
    override func setUp() {
        ConfigurationManager.shared.configure()
    }
    
    func testSearchHints(){
        let testQuery = "Beat it"
        Autocompleter.getSearchHints(for: testQuery) { (songs) in
            XCTAssert(songs.count > 0)
        }
    }
    
    func testInvalidSearchHints(){
        let testQuery = ""
        Autocompleter.getSearchHints(for: testQuery) { (songs) in
            XCTAssert(songs.isEmpty)
        }
    }
}
