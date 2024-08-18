//
//  Weather.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct WeatherView: View {
    //MARK: - Properties
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true

    @StateObject var locationManager = LocationManager()

    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?

    var cityName: String?

    //MARK: - Body
    var body: some View {
        VStack {
            if let cityName = cityName {
                Text("\(cityName)")
                    .font(.headline .bold())
                    .padding(.bottom)

                if let weather = currentWeather {
                    WeatherDetailsView(weather: weather, iconsColorsBasedOnWeather: iconsColorsBasedOnWeather)
                }

                if let forecast = forecast {
                    ForecastView(forecast: forecast, iconsColorsBasedOnWeather: iconsColorsBasedOnWeather)
                }

                if airQuality {
                    if let pollution = pollution {
                        AirPollutionView(pollution: pollution)
                    }
                }

            }  else if locationManager.cityName != "Unknown" {
                Text("\(locationManager.cityName)")
                    .font(.headline .bold())
                    .padding(.bottom)

                if let weather = currentWeather {
                    WeatherDetailsView(weather: weather, iconsColorsBasedOnWeather: iconsColorsBasedOnWeather)
                }

                if let forecast = forecast {
                    ForecastView(forecast: forecast, iconsColorsBasedOnWeather: iconsColorsBasedOnWeather)
                }

                if airQuality {
                    if let pollution = pollution {
                        AirPollutionView(pollution: pollution)
                    }
                }
            } else {
                Text("Fetching location...")
            }

            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let cityName = cityName {
                    fetchWeatherData(for: cityName)
                } else if locationManager.cityName != "Unknown" {
                    fetchWeatherData(for: locationManager.cityName)
                } else {
                    errorMessage = "Unable to determine city name."
                }
            }
        }
    }

    //MARK: - Data Fetching
    private func fetchWeatherData(for city: String) {
        if city != "Unknown" {
            API.shared.fetchCurrentWeatherData(forCity: city) { result in
                switch result {
                case .success(let weatherData):
                    currentWeather = weatherData
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }

            API.shared.fetchForecastData(forCity: city) { result in
                switch result {
                case .success(let forecastData):
                    forecast = forecastData
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }

            API.shared.fetchAirPollutionData(forCity: city) { result in
                switch result {
                case .success(let pollutionData):
                    pollution = pollutionData
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        } else {
            errorMessage = "City name is Unknown. Cannot fetch weather data."
        }
    }
}

#Preview {
    WeatherView(cityName: "Zembrzyce")
}
