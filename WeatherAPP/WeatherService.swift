//
//  WeatherServices.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 03/08/2024.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()

    func fetchWeatherData(forCoordinates coordinates: (lat: Double, lon: Double)) async throws -> WeatherData {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.lat)&lon=\(coordinates.lon)&appid=e58dfbc15daacbeabeed6abc3e5d95ca&units=metric") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(WeatherData.self, from: data)
    }
}
