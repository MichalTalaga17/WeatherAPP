//
//  WeatherServices.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import Foundation
import CoreLocation
import WeatherKit

// Zmiana nazwy na bardziej właściwą dla Twojego przypadku
class WeatherService {
    private let weatherKit = WeatherKit.WeatherService() // Stwórz instancję WeatherService
    
    // Funkcja do pobierania pogody na podstawie lokalizacji
    func fetchWeather(for location: CLLocation) async throws -> Weather {
        let weather = try await weatherKit.weather(for: location)
        return weather
    }
}
