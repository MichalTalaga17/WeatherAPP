//
//  WeatherForecastPollutionWidget.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 25/08/2024.
//

import Foundation
import SwiftUI
import WidgetKit

// MARK: - WeatherForecastPollutionEntry
struct WeatherForecastPollutionEntry: TimelineEntry {
    let date: Date
    let cityName: String
    let currentTemperature: String
    let currentWeatherDescription: String
    let minTemperature: String
    let maxTemperature: String
    let weatherIcon: String
    let forecast: [ForecastDay]
    let aqi: Int
    let aqiDescription: String
    let pm25: Double
    let pm10: Double
    let currentHumidity: Int
    let currentPressure: Int
    let currentWindSpeed: Double
    let currentCloudCoverage: Int
}

struct WeatherForecastPollutionProvider: TimelineProvider {
    private let api = API.shared
    @ObservedObject private var locationManager = LocationManager()
    
    func placeholder(in context: Context) -> WeatherForecastPollutionEntry {
        WeatherForecastPollutionEntry(
            date: Date(),
            cityName: "Unknown",
            currentTemperature: "--",
            currentWeatherDescription: "Unknown",
            minTemperature: "--",
            maxTemperature: "--",
            weatherIcon: "01d",
            forecast: [],
            aqi: 0,
            aqiDescription: "Unknown",
            pm25: 0.0,
            pm10: 0.0,
            currentHumidity: 0,
            currentPressure: 0,
            currentWindSpeed: 0.0,
            currentCloudCoverage: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherForecastPollutionEntry) -> Void) {
        fetchCombinedData { entry in
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherForecastPollutionEntry>) -> Void) {
        fetchCombinedData { entry in
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                    let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                    
            completion(timeline)
        }
    }
    
    private func fetchCombinedData(completion: @escaping (WeatherForecastPollutionEntry) -> Void) {
        locationManager.requestLocation { result in
            switch result {
            case .success(_):
                let city = locationManager.cityName
                api.fetchCurrentWeatherData(forCity: city) { currentWeatherResult in
                    switch currentWeatherResult {
                    case .success(let currentWeatherData):
                        api.fetchForecastData(forCity: city) { forecastResult in
                            switch forecastResult {
                            case .success(let forecastData):
                                api.fetchAirPollutionData(forCity: city) { pollutionResult in
                                    switch pollutionResult {
                                    case .success(let pollutionData):
                                        let latestEntry = pollutionData.list.first ?? PollutionEntry(
                                            main: MainPollution(aqi: 0),
                                            components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0)
                                        )
                                        let forecast = forecastData.list.prefix(5).map { item in
                                            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                                            let temperature = "\(Int(item.main.temp))°"
                                            let weatherIcon = item.weather.first?.icon ?? "01d"
                                            return ForecastDay(date: date, temperature: temperature, weatherIcon: weatherIcon)
                                        }
                                        
                                        let minTemp = currentWeatherData.main.temp_min
                                        let maxTemp = currentWeatherData.main.temp_max

                                        let entry = WeatherForecastPollutionEntry(
                                            date: Date(),
                                            cityName: forecastData.city.name,
                                            currentTemperature: "\(Int(currentWeatherData.main.temp)) °C",
                                            currentWeatherDescription: currentWeatherData.weather.first?.description ?? "No description",
                                            minTemperature: "\(Int(minTemp)) °C",
                                            maxTemperature: "\(Int(maxTemp)) °C",
                                            weatherIcon: currentWeatherData.weather.first?.icon ?? "01d",
                                            forecast: forecast,
                                            aqi: latestEntry.main.aqi,
                                            aqiDescription: aqiDescription(for: latestEntry.main.aqi),
                                            pm25: latestEntry.components.pm2_5,
                                            pm10: latestEntry.components.pm10,
                                            currentHumidity: currentWeatherData.main.humidity,
                                            currentPressure: currentWeatherData.main.pressure,
                                            currentWindSpeed: currentWeatherData.wind.speed,
                                            currentCloudCoverage: currentWeatherData.clouds.all
                                        )
                                        completion(entry)
                                        
                                    case .failure(let error):
                                        print("Failed to fetch pollution data: \(error.localizedDescription)")
                                        let entry = WeatherForecastPollutionEntry(
                                            date: Date(),
                                            cityName: forecastData.city.name,
                                            currentTemperature: "\(Int(currentWeatherData.main.temp)) °C",
                                            currentWeatherDescription: currentWeatherData.weather.first?.description ?? "No description",
                                            minTemperature: "--",
                                            maxTemperature: "--",
                                            weatherIcon: currentWeatherData.weather.first?.icon ?? "01d",
                                            forecast: [],
                                            aqi: 0,
                                            aqiDescription: "Unknown",
                                            pm25: 0.0,
                                            pm10: 0.0,
                                            currentHumidity: currentWeatherData.main.humidity,
                                            currentPressure: currentWeatherData.main.pressure,
                                            currentWindSpeed: currentWeatherData.wind.speed,
                                            currentCloudCoverage: currentWeatherData.clouds.all
                                        )
                                        completion(entry)
                                    }
                                }
                                
                            case .failure(let error):
                                print("Failed to fetch forecast data: \(error.localizedDescription)")
                                let entry = WeatherForecastPollutionEntry(
                                    date: Date(),
                                    cityName: "Unknown",
                                    currentTemperature: "\(Int(currentWeatherData.main.temp)) °C",
                                    currentWeatherDescription: currentWeatherData.weather.first?.description ?? "No description",
                                    minTemperature: "--",
                                    maxTemperature: "--",
                                    weatherIcon: currentWeatherData.weather.first?.icon ?? "01d",
                                    forecast: [],
                                    aqi: 0,
                                    aqiDescription: "Unknown",
                                    pm25: 0.0,
                                    pm10: 0.0,
                                    currentHumidity: currentWeatherData.main.humidity,
                                    currentPressure: currentWeatherData.main.pressure,
                                    currentWindSpeed: currentWeatherData.wind.speed,
                                    currentCloudCoverage: currentWeatherData.clouds.all
                                )
                                completion(entry)
                            }
                        }
                        
                    case .failure(let error):
                        print("Failed to get current weather data: \(error.localizedDescription)")
                        completion(WeatherForecastPollutionEntry(
                            date: Date(),
                            cityName: "Unknown",
                            currentTemperature: "--",
                            currentWeatherDescription: "Unknown",
                            minTemperature: "--",
                            maxTemperature: "--",
                            weatherIcon: "01d",
                            forecast: [],
                            aqi: 0,
                            aqiDescription: "Unknown",
                            pm25: 0.0,
                            pm10: 0.0,
                            currentHumidity: 0,
                            currentPressure: 0,
                            currentWindSpeed: 0.0,
                            currentCloudCoverage: 0
                        ))
                    }
                }
                
            case .failure(let error):
                print("Failed to get location: \(error.localizedDescription)")
                completion(WeatherForecastPollutionEntry(
                    date: Date(),
                    cityName: "Unknown",
                    currentTemperature: "--",
                    currentWeatherDescription: "Unknown",
                    minTemperature: "--",
                    maxTemperature: "--",
                    weatherIcon: "01d",
                    forecast: [],
                    aqi: 0,
                    aqiDescription: "Unknown",
                    pm25: 0.0,
                    pm10: 0.0,
                    currentHumidity: 0,
                    currentPressure: 0,
                    currentWindSpeed: 0.0,
                    currentCloudCoverage: 0
                ))
            }
        }
    }

    func aqiDescription(for aqi: Int) -> String {
        switch aqi {
        case 1:
            return "Good"
        case 2:
            return "Fair"
        case 3:
            return "Moderate"
        case 4:
            return "Poor"
        case 5:
            return "Very Poor"
        default:
            return "Unknown"
        }
    }
}

struct WeatherForecastPollutionEntryView: View {
    var entry: WeatherForecastPollutionEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(entry.cityName)
                        .font(.headline)
                    HStack {
                        Text("Min: \(entry.minTemperature)")
                            .font(.subheadline)
                        Text("Max: \(entry.maxTemperature)")
                            .font(.subheadline)
                    }
                    Text(entry.currentWeatherDescription)
                }
                Spacer()
                Text(entry.currentTemperature)
                    .font(.largeTitle)
            }
            HStack {
                VStack {
                    Text("Humidity: \(entry.currentHumidity)%")
                    Text("Pressure: \(entry.currentPressure) hPa")
                    Text("Wind: \(entry.currentWindSpeed, specifier: "%.1f") m/s")
                    Text("Clouds: \(entry.currentCloudCoverage)%")
                }
                .font(.subheadline)
                .padding()
            }
            .border(Color.gray)
            
            Spacer()
            
            HStack {
                ForEach(entry.forecast) { day in
                    VStack {
                        Text(hourFormatter.string(from: day.date))
                            .font(.footnote)
                            .padding(.bottom, 4)
                        IconConvert(for: day.weatherIcon, useWeatherColors: true)
                            .padding(.bottom, 4)
                        Text(day.temperature)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Spacer()
            
            HStack(alignment: .top) {
                VStack {
                    Text("\(entry.aqiDescription)")
                        .foregroundColor(entry.aqiColor())
                    Text("Air Quality")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(entry.pm25, specifier: "%.1f")")
                    Text("PM2.5")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(entry.pm10, specifier: "%.1f")")
                    Text("PM10")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

extension WeatherForecastPollutionEntry {
    func aqiColor() -> Color {
        switch aqi {
        case 1:
            return .green
        case 2:
            return .yellow
        case 3:
            return .orange
        case 4:
            return .red
        case 5:
            return .purple
        default:
            return .gray
        }
    }
}

struct WeatherForecastPollutionWidget: Widget {
    let kind: String = "WeatherForecastPollutionWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherForecastPollutionProvider()) { entry in
            WeatherForecastPollutionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weather, Forecast & Air Quality Widget")
        .description("Displays current weather, forecast, and air quality information for a selected city.")
        .supportedFamilies([.systemLarge])
    }
}

#Preview(as: .systemLarge) {
    WeatherForecastPollutionWidget()
} timeline: {
    WeatherForecastPollutionEntry(
        date: Date(),
        cityName: "Warszawa",
        currentTemperature: "22 °C",
        currentWeatherDescription: "Clear sky",
        minTemperature: "18 °C",
        maxTemperature: "23 °C",
        weatherIcon: "01d",
        forecast: [
            ForecastDay(date: Date().addingTimeInterval(3600 * 24), temperature: "20°C", weatherIcon: "01d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 48), temperature: "18°C", weatherIcon: "02d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 72), temperature: "19°C", weatherIcon: "03d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 96), temperature: "20°C", weatherIcon: "01d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 120), temperature: "18°C", weatherIcon: "02d")
        ],
        aqi: 2,
        aqiDescription: "Fair",
        pm25: 12.5,
        pm10: 25.0,
        currentHumidity: 75,
        currentPressure: 1012,
        currentWindSpeed: 5.5,
        currentCloudCoverage: 50
    )
}
