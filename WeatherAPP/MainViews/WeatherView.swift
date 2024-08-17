//
//  Weather.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct WeatherView: View {
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    @StateObject var locationManager = LocationManager()
    
    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?
    
    var cityName: String? 
    
    var body: some View {
        VStack {
            if let cityName = cityName {
                Text("City: \(cityName)")
                    .font(.title)
                    .padding(.bottom)
                
                if let weather = currentWeather {
                    WeatherDetailsView(weather: weather)
                }
                
                if let forecast = forecast {
                    ForecastView(forecast: forecast)
                }
                
                if let pollution = pollution {
                    AirPollutionView(pollution: pollution)
                }
                
            } else if let location = locationManager.location {
                Text("City: \(locationManager.cityName)")
                    .font(.title)
                    .padding(.bottom)
                
                if let weather = currentWeather {
                    WeatherDetailsView(weather: weather)
                }
                
                if let forecast = forecast {
                    ForecastView(forecast: forecast)
                }
                
                if let pollution = pollution {
                    AirPollutionView(pollution: pollution)
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

struct WeatherDetailsView: View {
    let weather: CurrentData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            Text("Current Weather")
                .font(.headline)
                .padding(.top)
            
            // Weather Information
            Group {
                WeatherDetailRow(title: "Temperature", value: "\(Int(weather.main.temp))°C")
                WeatherDetailRow(title: "Feels Like", value: "\(Int(weather.main.feels_like))°C")
                WeatherDetailRow(title: "Min Temp", value: "\(Int(weather.main.temp_min))°C")
                WeatherDetailRow(title: "Max Temp", value: "\(Int(weather.main.temp_max))°C")
                WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
                WeatherDetailRow(title: "Pressure", value: "\(weather.main.pressure) hPa")
                WeatherDetailRow(title: "Cloudiness", value: "\(weather.clouds.all)%")
                WeatherDetailRow(title: "Visibility", value: "\(weather.visibility / 1000) km")
                WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
                
                if let rain = weather.rain?.hour1 {
                    WeatherDetailRow(title: "Rain", value: "\(rain) mm (1h)")
                }
                if let snow = weather.snow?.hour1 {
                    WeatherDetailRow(title: "Snow", value: "\(snow) mm (1h)")
                }
                
                WeatherDetailRow(title: "Sunrise", value: formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
                WeatherDetailRow(title: "Sunset", value: formatUnixTimeToHourAndMinute(weather.sys.sunset, timezone: weather.timezone))
                if let weatherDescription = weather.weather.first?.description {
                        WeatherDetailRow(title: "Description", value: weatherDescription.capitalized)
                                    
                                }
                if let icon = weather.weather.first?.icon {
                    IconConvert(for: icon, useWeatherColors: true)
                }
            }
            .padding(.horizontal)
        
            
            
            
        }
    }
}

struct WeatherDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .fontWeight(.bold)
        }
        .padding(.vertical, 4)
    }
}


struct ForecastView: View {
    let forecast: ForecastData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Forecast")
                .font(.headline)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(forecast.list.prefix(10), id: \.dt) { entry in
                        VStack {
                            Text("\(extractHour(from: entry.dt_txt))")
                            IconConvert(for: entry.weather.first?.icon ?? "", useWeatherColors: true)
                            Text("\(Int(entry.main.temp))°")
                            Text("\(Int(entry.main.feels_like))°")
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct AirPollutionView: View {
    let pollution: PollutionData
    
    var body: some View {
        ScrollView(.horizontal) {
            if let pollutionEntry = pollution.list.first {
                HStack {
                    VStack {
                        Text("\(Int(pollutionEntry.components.pm2_5))")
                        Text("PM2.5")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.components.pm10))")
                        Text("PM10")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.main.aqi))")
                        Text("AQI")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.components.co))")
                        Text("CO")
                    }
                    VStack {
                        Text("\(Int(pollutionEntry.components.no2))")
                        Text("NO2")
                    }
                }
            }
        }
        .padding()
    }
}

#Preview{
    WeatherView(cityName: "Zembrzyce")
}
