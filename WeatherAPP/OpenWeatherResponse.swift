//
//  OpenWeatherResponse.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import Foundation
import CoreLocation

// Model danych z odpowiedzi API OpenWeatherMap
struct OpenWeatherResponse: Codable {
    let weather: [WeatherDetails]
    let main: MainWeather
}

// Szczegóły pogody (np. opis, ikona)
struct WeatherDetails: Codable {
    let description: String
    let icon: String
}

// Dane pogodowe (np. temperatura)
struct MainWeather: Codable {
    let temp: Double
}

// Używamy OpenWeatherResponse do przechowywania pogody
struct Weather {
    let temperature: Double
    let condition: String
}
