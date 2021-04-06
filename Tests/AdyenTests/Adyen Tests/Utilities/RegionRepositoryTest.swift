//
//  RegionRepositoryTest.swift
//  AdyenUIKitTests
//
//  Created by Vladimir Abramichev on 22/04/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
import XCTest

class RegionRepositoryTest:  XCTestCase {

    let local = Environment(baseURL: Bundle(for: RegionRepositoryTest.self).url(forResource: "JSON", withExtension: nil)!)

    func testGettingListOfCountriesEN() {
        let sut = RegionRepository(environment: local)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        sut.getCountries(locale: "en-US") { (regions) in
            XCTAssertEqual(regions.count, 245)
            XCTAssertEqual(regions[15].name, "Azerbaijan")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testGettingListOfCountriesRU() {
        let sut = RegionRepository(environment: local)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        sut.getCountries(locale: "es-ES") { (regions) in
            XCTAssertEqual(regions.count, 245)
            XCTAssertEqual(regions[15].name, "Azerbaiyán")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testGettingListOfStatesUS() {
        let sut = RegionRepository(environment: local)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        sut.getSubRegions(for: "US", locale: "en-US") { (regions) in
            XCTAssertEqual(regions.count, 51)
            XCTAssertEqual(regions[15].name, "Iowa")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testGettingListOfStatesCA() {
        let sut = RegionRepository(environment: local)
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        sut.getSubRegions(for: "CA", locale: "en-CA") { (regions) in
            XCTAssertEqual(regions.count, 13)
            XCTAssertEqual(regions[2].name, "Manitoba")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

}
