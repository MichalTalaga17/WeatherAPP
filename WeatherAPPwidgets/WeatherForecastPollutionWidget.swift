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
    let weatherDescription: String
    let minTemperature: String
    let maxTemperature: String
    let weatherIcon: String
    let humidity: String
    let pressure: String
    let windSpeed: String
    let precipitation: String
    let cloudiness: String
    let forecast: [ForecastDay]
    let aqi: Int
    let aqiDescription: String
    let pm25: Double
    let pm10: Double
}

struct WeatherForecastPollutionProvider: TimelineProvider {
    private let api = API.shared
    
    func placeholder(in context: Context) -> WeatherForecastPollutionEntry {
        WeatherForecastPollutionEntry(
            date: Date(),
            cityName: "Unknown",
            currentTemperature: "--",
            weatherDescription: "Unknown",
            minTemperature: "--",
            maxTemperature: "--",
            weatherIcon: "01d",
            humidity: "--",
            pressure: "--",
            windSpeed: "--",
            precipitation: "--",
            cloudiness: "--",
            forecast: [],
            aqi: 0,
            aqiDescription: "Unknown",
            pm25: 0.0,
            pm10: 0.0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherForecastPollutionEntry) -> Void) {
        fetchCombinedData { entry in
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherForecastPollutionEntry>) -> Void) {
        fetchCombinedData { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    private func fetchCombinedData(completion: @escaping (WeatherForecastPollutionEntry) -> Void) {
        // Replace "Your City" with a valid city name or fetch it from a stored setting
        let city = "Your City"
        
        api.fetchForecastData(forCity: city) { forecastResult in
            switch forecastResult {
            case .success(let forecastData):
                api.fetchAirPollutionData(forCity: city) { pollutionResult in
                    switch pollutionResult {
                    case .success(let pollutionData):
                        let latestEntry = pollutionData.list.first ?? PollutionEntry(main: MainPollution(aqi: 0), components: PollutionComponents(co: 0, no: 0, no2: 0, o3: 0, so2: 0, pm2_5: 0, pm10: 0, nh3: 0))
                        let forecast = forecastData.list.prefix(5).map { item in
                            let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
                            let temperature = "\(Int(item.main.temp))°"
                            let weatherIcon = item.weather.first?.icon ?? "01d"
                            return ForecastDay(date: date, temperature: temperature, weatherIcon: weatherIcon)
                        }
                        
                        let entry = WeatherForecastPollutionEntry(
                            date: Date(),
                            cityName: forecastData.city.name,
                            currentTemperature: "\(Int(forecastData.list.first?.main.temp ?? 0))°",
                            weatherDescription: forecastData.list.first?.weather.first?.description.capitalized ?? "Unknown",
                            minTemperature: "\(Int(forecastData.list.min(by: { $0.main.temp_min < $1.main.temp_min })?.main.temp_min ?? 0))°",
                            maxTemperature: "\(Int(forecastData.list.max(by: { $0.main.temp_max < $1.main.temp_max })?.main.temp_max ?? 0))°",
                            weatherIcon: forecastData.list.first?.weather.first?.icon ?? "01d",
                            humidity: "\(Int(forecastData.list.first?.main.humidity ?? 0))%",
                            pressure: "\(Int(forecastData.list.first?.main.pressure ?? 0)) hPa",
                            windSpeed: "\(Int(forecastData.list.first?.wind.speed ?? 0)) m/s",
                            precipitation: "\(forecastData.list.first?.rain?.h1 ?? 0.0) mm",
                            cloudiness: "\(Int(forecastData.list.first?.clouds.all ?? 0))%",
                            forecast: forecast,
                            aqi: latestEntry.main.aqi,
                            aqiDescription: aqiDescription(for: latestEntry.main.aqi),
                            pm25: latestEntry.components.pm2_5,
                            pm10: latestEntry.components.pm10
                        )
                        completion(entry)
                        
                    case .failure(let error):
                        print("Failed to fetch pollution data: \(error.localizedDescription)")
                        let entry = WeatherForecastPollutionEntry(
                            date: Date(),
                            cityName: forecastData.city.name,
                            currentTemperature: "\(Int(forecastData.list.first?.main.temp ?? 0))°",
                            weatherDescription: forecastData.list.first?.weather.first?.description.capitalized ?? "Unknown",
                            minTemperature: "\(Int(forecastData.list.min(by: { $0.main.temp_min < $1.main.temp_min })?.main.temp_min ?? 0))°",
                            maxTemperature: "\(Int(forecastData.list.max(by: { $0.main.temp_max < $1.main.temp_max })?.main.temp_max ?? 0))°",
                            weatherIcon: forecastData.list.first?.weather.first?.icon ?? "01d",
                            humidity: "--",
                            pressure: "--",
                            windSpeed: "--",
                            precipitation: "--",
                            cloudiness: "--",
                            forecast: [],
                            aqi: 0,
                            aqiDescription: "Unknown",
                            pm25: 0.0,
                            pm10: 0.0
                        )
                        completion(entry)
                    }
                }
                
            case .failure(let error):
                print("Failed to fetch forecast data: \(error.localizedDescription)")
                let entry = WeatherForecastPollutionEntry(
                    date: Date(),
                    cityName: "Unknown",
                    currentTemperature: "--",
                    weatherDescription: "Unknown",
                    minTemperature: "--",
                    maxTemperature: "--",
                    weatherIcon: "01d",
                    humidity: "--",
                    pressure: "--",
                    windSpeed: "--",
                    precipitation: "--",
                    cloudiness: "--",
                    forecast: [],
                    aqi: 0,
                    aqiDescription: "Unknown",
                    pm25: 0.0,
                    pm10: 0.0
                )
                completion(entry)
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
                        .padding(.bottom, 2)
                    Text(entry.weatherDescription)
                        .font(.subheadline)
                    Text("Min: \(entry.minTemperature) Max: \(entry.maxTemperature)")
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(entry.currentTemperature)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    IconConvert(for: entry.weatherIcon, useWeatherColors: true)
                        .frame(width: 40, height: 40)
                }
            }
            Spacer().frame(height: 10)
            
            HStack {
                VStack {
                    Text("Humidity")
                        .font(.caption)
                    Text(entry.humidity)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Pressure")
                        .font(.caption)
                    Text(entry.pressure)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Wind")
                        .font(.caption)
                    Text(entry.windSpeed)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Precipitation")
                        .font(.caption)
                    Text(entry.precipitation)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("Cloudiness")
                        .font(.caption)
                    Text(entry.cloudiness)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer().frame(height: 10)
            
            HStack {
                ForEach(entry.forecast.prefix(5)) { day in
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
            
            Spacer().frame(height: 10)
            
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
        .padding()
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
        weatherDescription: "Clear Sky",
        minTemperature: "15°C",
        maxTemperature: "25°C",
        weatherIcon: "01d",
        humidity: "60%",
        pressure: "1015 hPa",
        windSpeed: "5 m/s",
        precipitation: "0.0 mm",
        cloudiness: "10%",
        forecast: [
            ForecastDay(date: Date(), temperature: "20°C", weatherIcon: "01d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 3), temperature: "18°C", weatherIcon: "02d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 6), temperature: "19°C", weatherIcon: "03d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 9), temperature: "20°C", weatherIcon: "01d"),
            ForecastDay(date: Date().addingTimeInterval(3600 * 12), temperature: "18°C", weatherIcon: "02d")
        ],
        aqi: 2,
        aqiDescription: "Fair",
        pm25: 12.5,
        pm10: 25.0
    )
}
