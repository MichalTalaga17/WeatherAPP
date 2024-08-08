//
//  SimpleWeather.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 08/08/2024.
//

import Foundation

struct SimpleWeather: Codable {
    let cityName: String
    let temperature: Double
    let icon: String
}
