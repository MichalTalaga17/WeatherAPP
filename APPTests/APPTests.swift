//
//  APPTests.swift
//  APPTests
//
//  Created by Michał Talaga on 05/08/2024.
//

import XCTest
@testable import WeatherAPP

class WeatherUtilsTests: XCTestCase {

    // Test for kelvinToCelsius
    func testKelvinToCelsius() {
        XCTAssertEqual(kelvinToCelsius(273.15), "0 °C")
        XCTAssertEqual(kelvinToCelsius(0), "-273 °C")
        XCTAssertEqual(kelvinToCelsius(300), "27 °C")
    }
    
    
    // Test for dateToTimestamp
    func testDateToTimestamp() {
        XCTAssertEqual(dateToTimestamp(dateString: "2021-06-01 00:00:00"), 1622505600)
        XCTAssertNil(dateToTimestamp(dateString: "invalid-date"))
        XCTAssertEqual(dateToTimestamp(dateString: "1970-01-01 00:00:00"), 0)
    }
}
