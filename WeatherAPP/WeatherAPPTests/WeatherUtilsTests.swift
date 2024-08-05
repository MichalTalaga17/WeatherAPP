//
//  WeatherUtilsTests.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 05/08/2024.
//

import XCTest

class WeatherUtilsTests: XCTestCase {

    // Test for kelvinToCelsius
    func testKelvinToCelsius() {
        XCTAssertEqual(kelvinToCelsius(273.15), "0 °C")
        XCTAssertEqual(kelvinToCelsius(0), "-273 °C")
        XCTAssertEqual(kelvinToCelsius(300), "27 °C")
    }
    
    // Test for formatDate
    func testFormatDate() {
        let timestamp = 1622548800 // June 1, 2021 00:00:00 GMT

        XCTAssertEqual(formatDate(timestamp: timestamp, formatType: .fullDateTime), "01.06.2021 00:00")
        XCTAssertEqual(formatDate(timestamp: timestamp, formatType: .dayOfWeek), "Tuesday")
        XCTAssertEqual(formatDate(timestamp: timestamp, formatType: .timeOnly), "00:00")
        XCTAssertEqual(formatDate(timestamp: timestamp, formatType: .dateOnly), "01.06.2021")
        XCTAssertEqual(formatDate(timestamp: timestamp, formatType: .dateWithMonthName), "01 June 2021")
    }
    
    // Test for dateToTimestamp
    func testDateToTimestamp() {
        XCTAssertEqual(dateToTimestamp(dateString: "2021-06-01 00:00:00"), 1622505600)
        XCTAssertNil(dateToTimestamp(dateString: "invalid-date"))
        XCTAssertEqual(dateToTimestamp(dateString: "1970-01-01 00:00:00"), 0)
    }
}

WeatherUtilsTests.defaultTestSuite.run()

