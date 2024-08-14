//
//  Models.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 10/08/2024.
//

import Foundation
import WidgetKit
import SwiftUI

// MARK: - Model danych dla prognozy

struct ForecastEntry: TimelineEntry {
    let date: Date
    let forecast: [ForecastItem]
    let timeZone: TimeZone
    let cityName: String
}

struct ForecastItem {
    let time: Int
    let temperature: Double
    let iconName: String
}

// MARK: - Model danych dla podstawowego widgetu

struct SimpleEntry: TimelineEntry {
    let date: Date
    let city: String
    let temperature: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let cloudiness: Int
    let visibility: Int
    let sunrise: Date
    let sunset: Date
    let icon: String
}

struct PollutionEntry2: TimelineEntry {
    let date: Date
    let pollution: PollutionData
    let timeZone: TimeZone
    let cityName: String
}
