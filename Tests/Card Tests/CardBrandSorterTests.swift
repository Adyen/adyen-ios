//
//  CardBrandSorterTests.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 10/20/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

class CardBrandSorterTests: XCTestCase {
    
    let visa = CardBrand(type: .visa)
    let masterCard = CardBrand(type: .masterCard)
    let carteBancaire = CardBrand(type: .carteBancaire)
    let plcc = CardBrand(type: .other(named: "someplcc"))
    let cbcc = CardBrand(type: .other(named: "_cbcc_"))

    func testLessThanTwoBrands() {
        let brands = [visa]
        XCTAssertEqual(brands, CardBrandSorter.sortBrands(brands))
        XCTAssertEqual([], CardBrandSorter.sortBrands([]))
    }
    
    func testTwoBrands() {
        XCTAssertEqual(CardBrandSorter.sortBrands([carteBancaire, visa]), [visa, carteBancaire])
        XCTAssertEqual(CardBrandSorter.sortBrands([visa, carteBancaire]), [visa, carteBancaire])
        
        XCTAssertEqual(CardBrandSorter.sortBrands([masterCard, plcc]), [plcc, masterCard])
        XCTAssertEqual(CardBrandSorter.sortBrands([cbcc, masterCard]), [cbcc, masterCard])
        
        XCTAssertEqual(CardBrandSorter.sortBrands([carteBancaire, plcc]), [plcc, carteBancaire])
        XCTAssertEqual(CardBrandSorter.sortBrands([masterCard, visa]), [masterCard, visa])
        XCTAssertEqual(CardBrandSorter.sortBrands([carteBancaire, masterCard]), [carteBancaire, masterCard])
        
        XCTAssertTrue(cbcc.isPrivateLabeled)
        XCTAssertTrue(plcc.isPrivateLabeled)
        XCTAssertFalse(carteBancaire.isPrivateLabeled)
    }
    
    func testMoreThanTwoBrands() {
        let brands1 = [carteBancaire, visa, masterCard]
        let brands2 = [masterCard, plcc, cbcc, visa]
        let brands3 = [plcc, carteBancaire, visa, masterCard, cbcc]
        let brands4 = [visa, plcc, carteBancaire]
        
        XCTAssertEqual(CardBrandSorter.sortBrands(brands1), brands1)
        XCTAssertEqual(CardBrandSorter.sortBrands(brands2), brands2)
        XCTAssertEqual(CardBrandSorter.sortBrands(brands3), brands3)
        XCTAssertEqual(CardBrandSorter.sortBrands(brands4), brands4)
    }

}
