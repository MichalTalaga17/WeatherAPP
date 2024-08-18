//
//  Weather.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct WeatherView: View {
    // MARK: - Properties
    @AppStorage("airQuality") private var airQuality: Bool = true
    @AppStorage("iconsColorsBasedOnWeather") private var iconsColorsBasedOnWeather: Bool = true
    
    @StateObject var locationManager = LocationManager()
    
    @State private var currentWeather: CurrentData?
    @State private var forecast: ForecastData?
    @State private var pollution: PollutionData?
    @State private var errorMessage: String?
    
    var cityName: String?
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if let weather = currentWeather {
                    VStack(alignment: .center, spacing: 10) {
                        if let cityName = cityName, !cityName.isEmpty {
                            Text("\(weather.name), \(weather.sys.country)")
                                .font(.title3)
                        } else {
                            Text(locationManager.cityName)
                                .font(.title3)
                        }
                        
                        Text("\(Int(weather.main.temp))°")
                            .font(.system(size: 80))
                        if let weatherDescription = weather.weather.first?.description {
                            Text(weatherDescription.capitalized)
                        }
                        Text("From \(Int(weather.main.temp_min))° to \(Int(weather.main.temp_max))°")
                            .font(.callout)
                        
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 2), spacing: 10) {
                            // Sunrise and Sunset
                            WeatherDetailRow(title: "Sunrise", value: formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
                            WeatherDetailRow(title: "Sunset", value: formatUnixTimeToHourAndMinute(weather.sys.sunset, timezone: weather.timezone))
                            
                            // Cloudiness and Visibility
                            WeatherDetailRow(title: "Clouds", value: "\(weather.clouds.all)%")
                            WeatherDetailRow(title: "Visibility", value: "\(weather.visibility / 1000) km")
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        
                        // Weather details
                        VStack {
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
                                WeatherDetailRow(title: "Humidity", value: "\(weather.main.humidity)%")
                                WeatherDetailRow(title: "Pressure", value: "\(weather.main.pressure) hPa")
                            }
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 0), count: 2), spacing: 0) {
                                WeatherDetailRow(title: "Wind Speed", value: "\(Int(weather.wind.speed)) m/s")
                                WeatherDetailRow(title: "Precipitation", value: getPrecipitationInfo(weather))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                
                // Forecast
                if let forecast = forecast {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(forecast.list.prefix(10), id: \.dt) { entry in
                                VStack {
                                    Text("\(extractHour(from: entry.dt_txt))")
                                    IconConvert(for: entry.weather.first?.icon ?? "", useWeatherColors: iconsColorsBasedOnWeather)
                                    Text("\(Int(entry.main.temp))°")
                                        .font(.title2 .bold())
                                    Text("\(Int(entry.main.feels_like))°")
                                        .font(.callout)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.15)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Air Pollution
                if airQuality, let pollution = pollution {
                    if let pollutionEntry = pollution.list.first {
                        PollutionDataView(pollutionEntry: pollutionEntry)
                    }
                }
                
                // Fetching or Error Message
                if currentWeather == nil && forecast == nil && pollution == nil {
                    Text("Fetching data...")
                }
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding(.top)
                }
            }
            .padding()
        }
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
    
    // MARK: - Data Fetching
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
    
    // Helper function for precipitation information
    private func getPrecipitationInfo(_ weather: CurrentData) -> String {
        if let rain = weather.rain?.hour1 {
            return "\(rain) mm (1h)"
        } else if let snow = weather.snow?.hour1 {
            return "\(snow) mm (1h)"
        } else {
            return "0"
        }
    }
}

struct PollutionDataView: View {
    let pollutionEntry: PollutionEntry // assuming this is the type of data in pollution.list.first

    var body: some View {
        HStack{
            PollutionDataDetail(value: "\(aqiDescription(for: pollutionEntry.main.aqi))", label: "AQI")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.pm2_5))", label: "PM2.5")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.pm10))", label: "PM10")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.co))", label: "CO")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.no))", label: "NO")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.no2))", label: "NO2")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.o3))", label: "O3")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.so2))", label: "SO2")
                    PollutionDataDetail(value: "\(Int(pollutionEntry.components.nh3))", label: "NH3")
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
}

struct PollutionDataDetail: View {
    let value: String
    let label: String

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
        }
    }
}

struct WeatherDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
            }
            Spacer()
        }
    }
}

#Preview {
    WeatherView(cityName: "Zembrzyce")
}
