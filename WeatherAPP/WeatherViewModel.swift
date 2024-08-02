//
//  WeatherViewModel.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 02/08/2024.
//

import Foundation
import SwiftUI
import WeatherKit
import CoreLocation


class WeatherViewModel: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
    private let weatherService = WeatherService()
    @Published var weather: Weather?

    func fetchWeather(for cityName: String) {
        geocode(cityName: cityName)
    }

    private func geocode(cityName: String) {
        geocoder.geocodeAddressString(cityName) { [weak self] placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                return
            }

            guard let location = placemarks?.first?.location else {
                print("No location found for city: \(cityName)")
                return
            }

            self?.fetchWeather(for: location)
        }
    }

    private func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                DispatchQueue.main.async {
                    self.weather = weather
                }
            } catch {
                print("Failed to fetch weather data: \(error)")
            }
        }
    }
}
