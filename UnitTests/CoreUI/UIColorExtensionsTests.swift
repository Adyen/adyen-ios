//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class UIColorExtensionsTests: XCTestCase {
    
    func test12bitHexToColorConversion() {
        let white = UIColor(hexString: "FFF")
        let black = UIColor(hexString: "000")
        let blue = UIColor(hexString: "00F")
        let green = UIColor(hexString: "0F0")
        let red = UIColor(hexString: "F00")
        let pink = UIColor(hexString: "E7A")
        
        XCTAssertEqual(white, UIColor(red: 1, green: 1, blue: 1, alpha: 1))
        XCTAssertEqual(black, UIColor(red: 0, green: 0, blue: 0, alpha: 1))
        XCTAssertEqual(blue, UIColor(red: 0, green: 0, blue: 1, alpha: 1))
        XCTAssertEqual(green, UIColor(red: 0, green: 1, blue: 0, alpha: 1))
        XCTAssertEqual(red, UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        XCTAssertEqual(pink, UIColor(red: 238 / 255, green: 119 / 255, blue: 170 / 255, alpha: 1))
    }
    
    func test12bitHexToColorConversionWithAlpha() {
        let blueWithAlpha = UIColor(hexString: "00F", alpha: 0.5)
        
        XCTAssertEqual(blueWithAlpha, UIColor(red: 0, green: 0, blue: 1, alpha: 0.5))
    }
    
    func test24bitHexToColorConversion() {
        let white = UIColor(hexString: "FFFFFF")
        let black = UIColor(hexString: "000000")
        let blue = UIColor(hexString: "0000FF")
        let green = UIColor(hexString: "00FF00")
        let red = UIColor(hexString: "FF0000")
        let softPink = UIColor(hexString: "FFC0CB")
        
        XCTAssertEqual(white, UIColor(red: 1, green: 1, blue: 1, alpha: 1))
        XCTAssertEqual(black, UIColor(red: 0, green: 0, blue: 0, alpha: 1))
        XCTAssertEqual(blue, UIColor(red: 0, green: 0, blue: 1, alpha: 1))
        XCTAssertEqual(green, UIColor(red: 0, green: 1, blue: 0, alpha: 1))
        XCTAssertEqual(red, UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        XCTAssertEqual(softPink, UIColor(red: 255 / 255, green: 192 / 255, blue: 203 / 255, alpha: 1))
    }
    
    func test24bitHexToColorConversionWithAlpha() {
        let blueWithAlpha = UIColor(hexString: "0000FF", alpha: 0.5)
        
        XCTAssertEqual(blueWithAlpha, UIColor(red: 0, green: 0, blue: 1, alpha: 0.5))
    }
}
