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
        if currentWeather == nil && forecast == nil && pollution == nil {
            VStack{
                
                ProgressView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
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
            .border(Color.white)
        }else{
            ScrollView {
                VStack(alignment: .center) {
                    if let weather = currentWeather {
                        VStack(alignment: .center) {
                            VStack{
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
                            }
                            .padding(.bottom)
                            
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 10), count: 2), spacing: 10) {
                                VStack{
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        HStack(spacing: 15){
                                            VStack{
                                                IconConvert(for: "sunrise.fill", useWeatherColors: iconsColorsBasedOnWeather)
                                                Text(formatUnixTimeToHourAndMinute(weather.sys.sunrise, timezone: weather.timezone))
                                            }
                                            VStack{
                                                IconConvert(for: "sunset.fill", useWeatherColors: iconsColorsBasedOnWeather)
                                                Text(formatUnixTimeToHourAndMinute(weather.sys.sunset, timezone: weather.timezone))
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                    
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                
                                VStack{
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        HStack(alignment: .center) {
                                            if let icon = weather.weather.first?.icon {
                                                IconConvert(for: icon, useWeatherColors: iconsColorsBasedOnWeather)
                                            }
                                            VStack{
                                                Text("\(weather.clouds.all)%")
                                                    .font(.title2 .bold())
                                                Text("\(weather.visibility / 1000) km")
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
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
                    
                    
                    
                    
                    if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding(.top)
                    }
                }
                .padding()
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
    let pollutionEntry: PollutionEntry
    
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
                .font(.title2 .bold())
            Text(label)
                .font(.caption)
        }
        .frame(width: UIScreen.main.bounds.width * 0.15)
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
                    .font(.title2 .bold())
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
