//
//  WeatherView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 03/08/2024.
//

import SwiftUI

struct WeatherView: View {
    let coordinates: (lat: Double, lon: Double)
    @State private var weatherData: WeatherData?

    var body: some View {
        VStack {
            if let weatherData = weatherData {
                Text("Pogoda w \(weatherData.name)")
                    .font(.title)
                Text("Temperatura: \(weatherData.main.temp, specifier: "%.1f") °C")
                // ... (pozostałe elementy)
            } else {
                // ...
            }
        }
        .onAppear {
            Task {
                do {
                    weatherData = try await WeatherService.shared.fetchWeatherData(forCoordinates: coordinates)
                } catch {
                    // Obsługa błędów
                }
            }
        }
    }
}


#Preview {
    WeatherView(coordinates: (17.324, 18.843))
}
