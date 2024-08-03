//
//  Models.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 03/08/2024.
//

import Foundation

// Struktura reprezentująca dane pogodowe
struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

// Struktura reprezentująca pojedynczy opis pogody
struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
}

// Struktura reprezentująca główne informacje o pogodzie (temperatura, wilgotność itp.)
struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let humidity: Int
    let pressure: Int
}
