//
//  Weather.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct WeatherView: View {
    @StateObject var locationManager = LocationManager()

    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let location = locationManager.location {
                Text("City: \(locationManager.cityName)")
                    .font(.title)
                    .padding(.bottom)
                
                Text("Latitude: \(location.coordinate.latitude)")
                Text("Longitude: \(location.coordinate.longitude)")
                
                if let weather = currentWeather {
                    VStack(alignment: .leading) {
                        Text("Current Weather")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("Temperature: \(weather.main.temp)°C")
                        Text("Feels Like: \(weather.main.feels_like)°C")
                        Text("Humidity: \(weather.main.humidity)%")
                        Text("Wind Speed: \(weather.wind.speed) m/s")
                        if let rain = weather.rain?.hour1 {
                            Text("Rain: \(rain) mm (1h)")
                        }
                        if let snow = weather.snow?.hour1 {
                            Text("Snow: \(snow) mm (1h)")
                        }
                    }
                    .padding(.top)
                }

                if let forecast = forecast {
                    VStack(alignment: .leading) {
                        Text("Forecast")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(forecast.list.prefix(3), id: \.dt) { entry in
                            Text("Date: \(entry.dt_txt)")
                            Text("Temperature: \(entry.main.temp)°C")
                            Text("Weather: \(entry.weather.first?.description.capitalized ?? "")")
                        }
                    }
                    .padding(.top)
                }
                
                if let pollution = pollution {
                    VStack(alignment: .leading) {
                        Text("Air Pollution")
                            .font(.headline)
                            .padding(.top)
                        
                        if let pollutionEntry = pollution.list.first {
                            Text("AQI: \(pollutionEntry.main.aqi)")
                            Text("CO: \(pollutionEntry.components.co) μg/m3")
                            Text("NO2: \(pollutionEntry.components.no2) μg/m3")
                            Text("PM2.5: \(pollutionEntry.components.pm2_5) μg/m3")
                            Text("PM10: \(pollutionEntry.components.pm10) μg/m3")
                        }
                    }
                    .padding(.top)
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
                if locationManager.cityName != "Unknown" {
                    fetchWeatherData()
                } else {
                    errorMessage = "Unable to determine city name."
                }
            }
        }
    }
    
    private func fetchWeatherData() {
        let city = locationManager.cityName
        print("City used for API call: \(city)")
        
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
    WeatherView()
}
