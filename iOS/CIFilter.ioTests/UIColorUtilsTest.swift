//
//  UIColorUtilsTest.swift
//  CIFilter.ioTests
//
//  Created by Noah Gilmore on 2/6/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import CIFilter_io

class UIColorUtilsTest: XCTestCase {
    func testFromHexString() {
        let color = UIColor(hexString: "#FFFFFF")!
        XCTAssertEqual(color.cgColor.numberOfComponents, 4)
        XCTAssertEqual(color.cgColor.components, [1.0, 1.0, 1.0, 1.0])
    }

    func testColoredHexString() {
        let color = UIColor(hexString: "#1246B6")!
        XCTAssertEqual(color.cgColor.numberOfComponents, 4)
        XCTAssertEqual(color.cgColor.components![0], CGFloat(0.0705), accuracy: 0.0001)
    }

    func testLowercaseHexString() {
        let color = UIColor(hexString: "#ac46b6")!
        XCTAssertEqual(color.cgColor.numberOfComponents, 4)
        XCTAssertEqual(color.cgColor.components![0], CGFloat(0.6745), accuracy: 0.0001)
    }

    func testAlpha() {
        let color = UIColor(hexString: "#FFFFFFFF")!
        XCTAssertEqual(color.cgColor.numberOfComponents, 4)
        XCTAssertEqual(color.cgColor.components, [1.0, 1.0, 1.0, 1.0])
    }

    func testMiddleAlphaValue() {
        let color = UIColor(hexString: "#ac46b6a6")!
        XCTAssertEqual(color.cgColor.numberOfComponents, 4)
        XCTAssertEqual(color.cgColor.components![0], CGFloat(0.6745), accuracy: 0.0001)
        XCTAssertEqual(color.cgColor.components![3], CGFloat(0.6509), accuracy: 0.0001)
    }

    func testInvalid() {
        XCTAssertNil(UIColor(hexString: "#bd63"))
        XCTAssertNil(UIColor(hexString: "#"))
        XCTAssertNil(UIColor(hexString: ""))
        XCTAssertNil(UIColor(hexString: "hjklfg"))
    }
}
